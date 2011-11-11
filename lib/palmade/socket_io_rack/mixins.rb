module Palmade::SocketIoRack
  module Mixins
    autoload :Rainbows, File.join(SOCKET_IO_RACK_LIB_DIR, 'socket_io_rack/mixins/rainbows')
    autoload :Thin, File.join(SOCKET_IO_RACK_LIB_DIR, 'socket_io_rack/mixins/thin')
  end
end
