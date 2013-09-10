# encoding : utf-8

module Reactor
  # Хэндлер получения/обработки данных от клиента
  # подклассам нужно реализовать следующие методы
  #
  #  #before_init          - вызывается при инициализации
  #  #receive_data(chunk)  - вызывается при получении данных
  #  #connection_completed - вызывается при закрытии соединения
  #  #unbind               - вызывается при обрыве соединения
  #
  class DataHandler < EventHandler
    for_events READ_EVENT, ERROR_EVENT, HANGUP_EVENT

    DATA_BLOCK_SIZE = 4096

    protected

    # вызывается при инициализации
    def before_init
    end

    # вызывается при получении данных
    #
    # @param chunk [String] прочитанный фрагмент
    #
    def receive_data(chunk)
    end

    # вызывается при закрытии соединения
    def connection_completed
    end

    # вызывается при обрыве соединения
    def unbind
    end

    # непереопределяемый!
    #
    # @param chunk [String]
    #
    def send_data(chunk)
      # TODO: сделать буферизированную отправку
      handle.print chunk
    end

    # непереопределяемый!
    def close_connection
      unsubscribe!
      handle.close
      connection_completed
    end

    public

    # непереопределяемый!
    # обработчик событий чтения
    def handle_read
      receive_data handle.recv(DATA_BLOCK_SIZE)
    end

    # непереопределяемый!
    # обработчик ошибок
    def handle_error
      unbind
      close_connection rescue nil
    end
    alias :handle_hangup :handle_error

    private

    # у метода повышен модификатор доступа
    # для подклассов определен соответствующий метод #before_init
    def before_watch
      manager.initializer.call(self) unless manager.initializer.nil?
      before_init
    end
  end
end