# encoding : utf-8

module Reactor
  # Базовый класс для хэндлеров
  class EventHandler
    attr_reader :handle, :connection_handler_class, :connection_handler_initializer

    # Хэндлеры регистрируют себя в диспетчере при инициализации
    #
    # socket - TCPSocket
    # connection_handler_class - Connection класс для обратных вызовов
    # &initializer - Proc для инициализации connection_handler_class
    def initialize(socket, connection_handler_class, &initializer)
      @connection_handler_class = connection_handler_class
      @connection_handler_initializer = initializer
      @handle = socket
      before_watch
      Dispatcher.instance.register_handler(self, self.class.events)
    end

    protected

    # обработчик Epoll событий
    def handle_event
      raise NotImplementedError
    end

    # дополнительные инициализации в подклассах
    def before_watch
    end

    class << self
      attr_accessor :events

      # регистрация событий Epoll получаемых хэндлером
      #
      # Examples:
      #
      #   watch_for SP::Epoll::IN, SP::Epoll::ERR
      #
      def watch_for(*events)
        raise ArgumentError, "Choose at least 1 event for watching" if events.empty?
        self.events = events
      end
    end
  end
end