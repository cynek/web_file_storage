# encoding : utf-8

module Reactor
  class DataHandler < EventHandler
    watch_for SP::Epoll::IN, SP::Epoll::ET
    attr_reader :connection

    def handle_event(event)
      case event
        when SP::Epoll::IN
          connection.receive_data handle.recv(4096)
        when SP::Epoll::OUT
        # TODO: разобраться почему блокируется ввод при этом событии
      end
    end

    def close_connection
      Dispatcher.instance.remove_handler self
      handle.close
      connection.connection_completed
    end

    private

    def before_watch
      @connection = connection_class.new(self.object_id)
    end
  end
end