# -*- encoding: binary -*-

module Palmade::SocketIoRack
  module Mixins
    module Thin
      autoload :Connection, File.expand_path('../thin/connection', __FILE__)
      autoload :FlashSocketConnection, File.expand_path('../thin/flashsocket_connection', __FILE__)
      autoload :WebSocketConnection, File.expand_path('../thin/websocket_connection', __FILE__)

      def self.included(thin)
        thin_connection = thin.const_get(:Connection)
        thin_connection.send(:include, Connection)
        thin_connection.send(:include, FlashSocketConnection)
      end
    end
  end
end
