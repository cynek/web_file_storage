# encoding : utf-8
require 'forwardable'

module Reactor
  # Базовый класс для хэндлеров
  class EventHandler
    extend Forwardable
    attr_reader :handle

    # Хэндлеры регистрируют себя в диспетчере при инициализации
    #
    # @param io [IO] IO объект для обработки
    # @param manager [Manager] содержит данные о диспетчере
    #
    def initialize(io, manager)
      @handle = io
      @manager = manager
      before_watch
      dispatcher.register_handler(self, self.class.events)
    end

    # обработчик событий чтения
    def handle_read
    end

    # обработчик событий записи
    def handle_write
    end

    # обработчик ошибок
    def handle_error
    end

    # обработчик зависаний
    def handle_hangup
    end

    protected

    attr_reader :manager
    def_delegator :manager, :dispatcher

    # дополнительные инициализации в подклассах
    def before_watch
    end

    def unsubscribe!
      self.class.events.each do |event|
        dispatcher.remove_handler_event(self, event)
      end
    end

    class << self
      attr_accessor :events

      # События на которые хэндлер подпишется при инициализации
      # все события наследуются подклассами
      #
      # @param events [Array<Integer>]
      # @example LoggerHandler подписан на чтение, и обработку ошибок
      #
      #   class LoggerHandler
      #     watch_for READ_EVENT, ERROR_EVENT
      #     ...
      #   end
      #
      def for_events(*events)
        raise ArgumentError, "Choose at least 1 event for watching" if events.empty?
        singleton_class.class_eval do
          define_method('events') { events }
        end
      end
    end
  end
end