# encoding : utf-8

module Reactor
  # Хэндлер подключения клиентов
  class AcceptanceHandler < EventHandler
    for_events READ_EVENT, ERROR_EVENT, HANGUP_EVENT
    def_delegator :manager, :data_handler_class

    # обрабатывает событие чтения - подключение клиента
    def handle_read
      socket = accept_connection
      data_handler_class.new(socket, manager) if socket
    end

    # обработчик ошибок
    def handle_error
      unsubscribe!
    end
    alias :handle_hangup :handle_error

    private

    def accept_connection
      handle.accept_nonblock
    rescue Errno::EWOULDBLOCK, Errno::EAGAIN
    end
  end
end