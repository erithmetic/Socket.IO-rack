module Palmade::SocketIoRack
  module Transports
    class FlashSocket < WebSocket
      FLASH_SOCKET = "flashsocket".freeze

      def transport_name; FLASH_SOCKET; end
    end
  end
end
