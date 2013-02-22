require 'miu/plugin'

module Miu
  module Plugins
    class Sana
      include Miu::Plugin

      DEFAULT_PORT = Miu.default_port + 2

      class Handler
        def log(tag, time, record)
          p [tag, time, record]
          'OK'
        end

        def select(table, query)
          Groonga[table].select(query).map(&:attributes)
        rescue => e
          e.to_s
        end
      end

      def initialize(options)
        require 'groonga'
        require 'msgpack/rpc'
        migrate options
        run options
      end

      private

      def run(options)
        host = options[:host]
        port = options[:port]

        @server = MessagePack::RPC::Server.new
        @server.listen host, port, Handler.new

        [:TERM, :INT].each do |sig|
          Signal.trap(sig) { @server.stop }
        end

        @server.run
      end

      def migrate(options)
        path = options[:database]

        ::Groonga::Context.default_options = {:encoding => :utf8}
        if File.exist? path
          ::Groonga::Database.open path
        else
          ::Groonga::Database.create :path => path
        end

        ::Groonga::Schema.define do |schema|
          schema.create_table 'networks', :type => :patricia_trie, :key_type => :short_text
          schema.create_table 'rooms', :type => :patricia_trie, :key_type => :short_text
          schema.create_table 'users', :type => :patricia_trie, :key_type => :short_text
          schema.create_table 'messages', :type => :array
          schema.create_table 'terms', :type => :patricia_trie, :key_normalize => true, :default_tokenizer => :bigram

          schema.change_table 'networks' do |table|
            table.short_text 'name'
          end
          schema.change_table 'rooms' do |table|
            table.reference 'network', 'networks'
            table.short_text 'name'
          end
          schema.change_table 'users' do |table|
            table.reference 'network', 'networks'
            table.short_text 'name'
          end
          schema.change_table 'messages' do |table|
            table.reference 'network', 'networks'
            table.reference 'room', 'rooms'
            table.reference 'user', 'users'
            table.short_text 'type'
            table.short_text 'text'
            table.time 'time'
          end
          schema.change_table 'terms' do |table|
            table.index 'networks.name'
            table.index 'rooms.name'
            table.index 'users.name'
            table.index 'messages.type'
            table.index 'messages.text'
          end
        end
      end

      register :sana, :desc => %(miu groonga plugin 'sana') do
        desc 'start', %(start sana)
        option :bind, :type => :string, :default => '127.0.0.1', :desc => 'bind address', :aliases => '-a'
        option :port, :type => :numeric, :default => DEFAULT_PORT, :desc => 'listen port', :aliases => '-p'
        option :database, :type => :string, :default => 'db/groonga/sana.db', :desc => 'database path'
        def start
          Sana.new options
        end

        desc 'init', %(init sana config)
        def init
          empty_directory 'db/groonga'
          append_to_file 'config/miu.god', <<-CONF

God.watch do |w|
  w.dir = Miu.root
  w.log = Miu.root.join('log/sana.log')
  w.name = 'sana'
  w.start = 'bundle exec miu sana start'
  w.keepalive
end
          CONF
          append_to_file 'config/fluent.conf', <<-CONF

# to miu.plugin.sana
<match miu.output.**>
  type msgpack_rpc
  host localhost
  port #{DEFAULT_PORT}
</match>
          CONF
        end
      end
    end
  end
end
