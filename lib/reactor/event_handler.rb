# encoding : utf-8

module Reactor
  # Базовый класс для хэндлеров
  class EventHandler
    attr_reader :dispatcher, :handle, :connection_handler_class, :connection_handler_initializer

    # Хэндлеры регистрируют себя в диспетчере при инициализации
    #
    # dispatcher               - Dispatcher
    # socket                   - TCPSocket
    # connection_handler_class - Connection класс для обратных вызовов
    # initializer              - блок инициализации connection_handler_class
    #
    def initialize(dispatcher, socket, connection_handler_class, &initializer)
      @connection_handler_class = connection_handler_class
      @connection_handler_initializer = initializer
      @handle = socket
      @dispatcher = dispatcher
      before_watch
      @dispatcher.register_handler(self, self.class.events)
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

      # регистрация событий SP::Epoll получаемых хэндлером
      #
      # events - Integer
      #
      # Examples:
      #
      #   class LoggerHandler
      #     watch_for SP::Epoll::IN, SP::Epoll::ERR
      #     ...
      #   end
      #
      def watch_for(*events)
        raise ArgumentError, "Choose at least 1 event for watching" if events.empty?
        self.events = events
      end
    end
  end
end