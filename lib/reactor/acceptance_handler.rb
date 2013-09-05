# encoding : utf-8

module Reactor
  # Хэндлер подключения клиентов
  class AcceptanceHandler < EventHandler
    watch_for SP::Epoll::IN, SP::Epoll::ERR, SP::Epoll::HUP
    attr_reader :connections

    def handle_event(event)
      case event
        when SP::Epoll::IN
          accept_socket = accept_connection
          DataHandler.new(@dispatcher, accept_socket, connection_handler_class, &connection_handler_initializer)
        when SP::Epoll::ERR, SP::Epoll::HUP
          Dispatcher.instance.remove_handler self
          @running = false
      end
    end

    def running?
      @running
    end

    private

    def before_watch
      @running = true
    end

    def accept_connection
      handle.accept_nonblock
    rescue Errno::EINTR, Errno::EAGAIN
      IO.select([handle])
      retry
    end
  end
end