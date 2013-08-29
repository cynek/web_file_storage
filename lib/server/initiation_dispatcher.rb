# encoding : utf-8
require 'singleton'

module Server
  # Регистриует и уведомляет хэндлеры о событиях
  class InitiationDispatcher
    include Singleton

    def initialize
      @handlers = {}
      @epoll = SP::Epoll.new
    end

    def register_handler(event_handler, event_type)
      socket = event_handler.get_handle

      @handlers[socket] = event_handler
      @epoll.add(socket, event_type)
    end

    def remove_handler(event_handler)
      socket = event_handler.get_handle

      @handlers.delete socket
      @epoll.del(socket)
    end

    def handle_events(timeout = 0)
      @epoll.wait do |event, socket|
        @handlers[socket].handle_event event
      end
    end
  end
end