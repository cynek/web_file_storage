# encoding : utf-8
require 'singleton'
require 'set'

module Server
  # Регистриует и уведомляет хэндлеры о событиях
  class InitiationDispatcher
    include Singleton

    def initialize
      # обработчики событий для каждого сокета
      @socket_handlers = Hash.new do |events, socket|
        events[socket] = Hash.new {|handlers, event| handlers[event] = Set.new }
      end

      @epoll = SP::Epoll.new
    end

    def register_handler(event_handler, event_types)
      socket = event_handler.get_handle
      flags = event_types.inject(0) {|flags, event| flags | event }

      if @socket_handlers.include?(socket)
        @epoll.mod(socket, @epoll.events_for(socket) | flags)
      else
        @epoll.add(socket, flags)
      end

      event_types.each do |event_type|
        @socket_handlers[socket][event_type] << event_handler
      end
    end

    def remove_handler(event_handler, event_type)
      # TODO: сделать возможность передавать несколько событий

      socket = event_handler.get_handle
      @socket_handlers[socket][event_type].delete event_handler

      # если на сокете не осталось других обработчиков этого типа
      if @socket_handlers[socket][event_type].empty?
        @socket_handlers[socket].delete(event_type)

        # отключаем наблюдение за сокетом, если обрабочиков на нем больше нет
        if @socket_handlers[socket].empty?
          @socket_handlers.delete socket
          @epoll.del(socket)
        # иначе отключаем наблюдение только за событием на этом сокете
        else
          @epoll.mod(socket, @epoll.events_for(socket) & ~event_type)
        end
      end
    end

    def handle_events(timeout = 0)
      @epoll.wait do |event, socket|
        @socket_handlers[socket][event].each do |handler|
          handler.handle_event event
        end
      end
    end
  end
end