# encoding : utf-8

module Server
  class ReadHandler < EventHandler
    def initialize(connection_socket)
      @connection = connection_socket
      InitiationDispatcher.instance.register_handler(self, SP::Epoll::IN | SP::Epoll::ET)
    end

    def get_handle
      @connection
    end

    def handle_event(event)
      case event
        when SP::Epoll::IN
          puts @connection.recv(255)
          InitiationDispatcher.instance.remove_handler self
          @connection.close
      end
    end
  end
end