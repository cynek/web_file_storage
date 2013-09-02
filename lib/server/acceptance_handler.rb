# encoding : utf-8
Dir[File.join("#{File.dirname(__FILE__)}", '', '*.rb')].each { |file| require file }

module Server
  class AcceptanceHandler < EventHandler
    def initialize(server_socket, app, env)
      @server_socket = server_socket
      @app = app
      @env = env
      InitiationDispatcher.instance.register_handler(self, [SP::Epoll::IN])
    end

    def get_handle
      @server_socket
    end

    def handle_event(event)
      case event
        when SP::Epoll::IN
          connection = accept_connection
          ReadHandler.new(connection, @app, @env)
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

  def asd
    'asdasd'
  end
end
