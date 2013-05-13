require 'miu/rpc'
require 'groonga'

module Miu
  module Nodes
    module Sana
      class Server
        class Handler
          def select(table, query)
            Groonga[table].select(query).map(&:attributes)
          end
        end

        attr_reader :server

        def initialize(bind, port)
          @server = Miu::RPC::Server.new "tcp://#{bind}:#{port}", Handler.new
        end
      end
    end
  end
end
