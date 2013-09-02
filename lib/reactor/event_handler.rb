# encoding : utf-8

module Reactor
  # Базовый класс для хэндлеров
  class EventHandler
    attr_reader :handle, :connection_class
    @@events = []

    # Хэндлеры регистрируют себя в диспетчере при инициализации
    #
    # socket - TCPSocket
    # connection_class - Connection класс для обратных вызовов
    def initialize(socket, connection_class)
      @connection_class = connection_class
      @handle = socket
      before_watch
      Dispatcher.instance.register_handler(self, @@events)
    end

    protected

    def self.watch_for(*events)
      raise ArgumentError, "Choose at least 1 event for watching" if events.empty?
      @@events = events
    end

    def handle_event
      raise NotImplementedError
    end

    # дополнительные инициализации в подклассах
    def before_watch
    end
  end
end