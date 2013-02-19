require 'miu/store/strategy'

module Miu
  module Store
    module Strategies
      class Groonga
        include Miu::Store::Strategy

        def initialize(options)
          require 'groonga'
          migrate options
        end

        def log(tag, time, record)
          'OK'
        end

        private

        def migrate(options)
          ::Groonga::Context.default_options = {:encoding => :utf8}
          path = options[:database]

          if File.exist? path
            ::Groonga::Database.open path
          else
            ::Groonga::Database.create :path => path
          end

          ::Groonga::Schema.define do |schema|
            schema.create_table 'targets', :type => :patricia_trie, :key_type => :short_text
            schema.create_table 'users', :type => :patricia_trie, :key_type => :short_text
            schema.create_table 'messages', :type => :array
            schema.create_table 'terms', :type => :patricia_trie, :normalizer => :NormalizerAuto, :default_tokenizer => 'TokenBigram'

            schema.change_table 'targets' do |table|
            end
            schema.change_table 'users' do |table|
            end
            schema.change_table 'messages' do |table|
              table.reference 'target', 'targets'
              table.reference 'sender', 'users'
              table.short_text 'text'
              table.short_text 'type'
              table.time 'created_at'
            end
            schema.change_table 'terms' do |table|
              table.index 'messages.text'
            end
          end
        end
      end
    end

    register :groonga, Strategies::Groonga
  end
end
