# encoding : utf-8

module Reactor
  class AcceptanceHandler < EventHandler
    watch_for SP::Epoll::IN
    attr_reader :connections

    def handle_event(event)
      case event
        when SP::Epoll::IN
          accept_socket = accept_connection

          # сохраняем соединения для последующих уведомлений
          @connections[accept_socket] = DataHandler.new(accept_socket, connection_class).connection
      end
    end

    def stop_loop?
      @stop_loop
    end

    private

    def before_watch
      @connections = {}
    end

    def accept_connection
        handle.accept_nonblock
      rescue IO::WaitReadable, Errno::EINTR
        puts "SERVER SOCKET WAIT READABLE"
        IO.select([handle])
        retry
      end
  end
end