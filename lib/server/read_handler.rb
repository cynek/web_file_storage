# encoding : utf-8

module Server
  class ReadHandler < EventHandler
    def initialize(connection_socket)
      @connection = connection_socket
      InitiationDispatcher.instance.register_handler(self, [SP::Epoll::IN, SP::Epoll::ET, SP::Epoll::OUT])
    end

    def get_handle
      @connection
    end

    def handle_event(event)
      case event
        when SP::Epoll::IN
          received_str = (@connection.recv(255)).strip
          if received_str == 'END'
            InitiationDispatcher.instance.remove_handler self, SP::Epoll::IN
            InitiationDispatcher.instance.remove_handler self, SP::Epoll::ET
            @connection.close
          else
            puts "RECEIVED #{received_str} SIZE #{received_str.size}"
          end
        when SP::Epoll::OUT
        # TODO: разобраться почему блокируется ввод при этом событии
          @connection.puts "RECEIVED BY #{Process.pid}"
      end
    end
  end
end