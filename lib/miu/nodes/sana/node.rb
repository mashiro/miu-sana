require 'miu'
require 'groonga'
require 'fileutils'

require 'miu/nodes/sana/server'
require 'miu/nodes/sana/subscriber'

module Miu
  module Nodes
    module Sana
      class Node
        include Miu::Node
        description 'Logging node for miu'

        DEFAULT_PORT = Miu.default_port + 37

        attr_reader :server, :subscriber
        attr_reader :options

        def initialize(options)
          @options = options

          Miu::Logger.info "Options:"
          @options.each do |k, v|
            Miu::Logger.info "  #{k}: #{v}"
          end

          establish options[:database]

          @server = Server.new options[:bind], options[:port]
          @subscriber = Subscriber.new options['sub-host'], options['sub-port'], options['sub-tag']
          @subscriber.async.run

          [:INT, :TERM].each do |sig|
            trap(sig) { exit }
          end

          sleep
        end

        private

        def establish(path)
          FileUtils.mkdir_p File.dirname(path)

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
              table.short_text 'text'
              table.short_text 'meta'
              table.time 'time'
            end
            schema.change_table 'terms' do |table|
              table.index 'networks.name'
              table.index 'rooms.name'
              table.index 'users.name'
              table.index 'messages.text'
            end
          end
        end

        register :sana do
          desc 'start', %(Start miu-sana node)
          option :bind, :type => :string, :default => '127.0.0.1', :desc => 'bind address', :aliases => '-a'
          option :port, :type => :numeric, :default => DEFAULT_PORT, :desc => 'listen port', :aliases => '-p'
          option :database, :type => :string, :default => 'db/groonga/sana.db', :desc => 'database path'
          add_miu_sub_options 'miu.input.'
          def start
            Node.new options
          end

          desc 'init', %(Generates a miu-sana configurations)
          def init
            config <<-EOS
Miu.watch 'sana' do |w|
  w.start = 'miu sana start'
  w.keepalive
end
            EOS
          end
        end
      end
    end
  end
end
