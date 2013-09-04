# encoding : utf-8

module Reactor
  # Хэндлер получения данных от клиента
  class DataHandler < EventHandler
    watch_for SP::Epoll::IN, SP::Epoll::ET, SP::Epoll::ERR, SP::Epoll::HUP

    DATA_BLOCK_SIZE = 4096

    attr_reader :connection_handler

    def handle_event(event)
      case event
        when SP::Epoll::IN
          while data = handle.recv(DATA_BLOCK_SIZE)
            connection_handler.receive_data data
          end
        when SP::Epoll::ERR, SP::Epoll::HUP
          Dispatcher.instance.remove_handler self
          connection_handler.unbind
      end
    end

    def close_connection
      Dispatcher.instance.remove_handler self
      handle.close
      connection_handler.connection_completed
    end

    private

    def before_watch
      @connection_handler = connection_handler_class.new(self.object_id, &connection_handler_initializer)
    end
  end
end