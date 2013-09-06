# encoding : utf-8
require 'set'
require "sleepy_penguin/sp"

module Reactor
  READ_EVENT   = 1
  WRITE_EVENT  = 2
  ERROR_EVENT  = 4
  HANGUP_EVENT = 8

  class Dispatcher
    # Диспетчер регистриует и уведомляет хэндлеры о событиях

    EPOLL_EVENTS = {
        Reactor::READ_EVENT    => SP::Epoll::IN,
        Reactor::WRITE_EVENT   => SP::Epoll::OUT,
        Reactor::ERROR_EVENT   => SP::Epoll::ERR,
        Reactor::HANGUP_EVENT  => SP::Epoll::HUP
    }

    def initialize
      @running = false
      @handlers = Hash.new do |events, io|
        events[io] = Hash.new {|handlers, event| handlers[event] = Set.new }
      end

      @epoll = SP::Epoll.new
    end

    def running?
      @running
    end

    # Главный цикл обработки событий
    #
    def run
      raise RuntimeError, "already running" if running?
      @running = true

      while running?
        handle_events
      end
    ensure
      @handlers.keys.each do |io|
        io.close
      end
      @handlers.clear
      @running = false
    end

    # Подписать хэндлер
    #
    # @param handler [EventHandler]
    # @param events [Array<Integer>] список событий, на которые нужно подписать
    #
    def register_handler(handler, events)
      io = handler.handle

      # включаем наблюдение
      enable_events_for(events, io)

      # заполняем список подписчиков
      events.each do |event|
        @handlers[io][event] << handler
      end
    end

    # Отписать хэндлер от события
    #
    # @param handler [EventHandler]
    # @param event [Integer]
    #
    def remove_handler_event(handler, event)
      io = handler.handle

      # исключаем из подписчиков
      @handlers[io][event].delete handler

      # отключаем наблюдение события IO, если на него больше никто не подписан
      disable_event_for(event, io) if @handlers[io][event].empty?
    end

    # Рассылка событий
    def handle_events
      @epoll.wait do |event, io|
        @handlers[io][event].each do |handler|
          case event
            when SP::Epoll::IN
              handler.handle_read
            when SP::Epoll::OUT
              handler.handle_write
            when SP::Epoll::ERR
              handler.handle_error
            when SP::Epoll::HUP
              handler.handle_hangup
          end
        end
      end
    end

    private

    # Включаем наблюдение событий IO
    #
    # @param events [Array<Integer>]
    # @param io [IO]
    #
    def enable_events_for(events, io)
      epoll_flags = epoll_flags_from(events)

      if @handlers.include?(io)
        @epoll.mod(io, @epoll.events_for(io) | epoll_flags)
      else
        @epoll.add(io, epoll_flags)
      end
    end

    # Отключаем наблюдение события IO
    #
    # @param event [Integer]
    # @param io [IO]
    #
    def disable_event_for(event, io)
      @handlers[io].delete(event)

      # полностью отключаем наблюдение IO, если подписчиков на нем больше нет
      if @handlers[io].empty?
        disable_all_for(io)
      # иначе отключаем наблюдение только за этим событием
      else
        @epoll.mod(io, @epoll.events_for(io) & ~EPOLL_EVENTS[event])
      end
    end

    def disable_all_for(io)
      @handlers.delete(io)
      @epoll.del(io)
    end

    def epoll_flags_from(events)
      events.inject(0) {|flags, event| flags | EPOLL_EVENTS[event] }
    end
  end
end