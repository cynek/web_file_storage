# encoding : utf-8

module Server
  class AcceptanceHandler < EventHandler
    def initialize(server_socket)
      @server_socket = server_socket
      InitiationDispatcher.instance.register_handler(self, [SP::Epoll::IN])
    end

    def get_handle
      @server_socket
    end

    def handle_event(event)
      case event
        when SP::Epoll::IN
          connection = accept_connection
          ReadHandler.new(connection)
      end
    end

    private

      def accept_connection
        @server_socket.accept_nonblock
      rescue IO::WaitReadable, Errno::EINTR
        puts "SERVER SOCKET WAIT READABLE"
        IO.select([@server_socket])
        retry
      end
  end
end