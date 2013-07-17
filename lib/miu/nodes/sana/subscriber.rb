require 'miu'
require 'groonga'

module Miu
  module Nodes
    module Sana
      class Subscriber
        include Miu::Subscriber
        include Celluloid::ZMQ
        socket_type Celluloid::ZMQ::SubSocket

        def initialize(*args)
          super
          @networks = Groonga['networks']
          @rooms = Groonga['rooms']
          @users = Groonga['users']
          @messages = Groonga['messages']
        end

        def on_text(topic, msg)
          add_message(msg)
          Miu::Logger.debug "[ADD] #{msg.inspect}"
        end

        private

        def add_message(msg)
          network_name = msg.network.name
          room_name = msg.room.name
          user_name = msg.user.name
          text = msg.text
          meta = MultiJson.encode msg.meta
          time = msg.time

          network = @networks[network_name] || @networks.add(network_name, :name => network_name)
          room = @rooms[room_name] || @rooms.add(room_name, :network => network, :name => room_name)
          user = @users[user_name] || @users.add(user_name, :network => network, :name => user_name)
          @messages.add({
            :network => network,
            :room => room,
            :user => user,
            :text => text,
            :meta => meta,
            :time => time
          })
        end
      end
    end
  end
end
