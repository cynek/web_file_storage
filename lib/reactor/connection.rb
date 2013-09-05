# encoding : utf-8

module Reactor
  # Класс управления подключением
  # Подклассы реализуют интерфейс обработки чтения, закрытия, обрыва соединения
  #
  # Examples:
  #
  #  class LoggerServer < Reactor::Connection
  #    attr_accessor :log
  #
  #    def receive_data(data)
  #      received_str = data.strip
  #      if received_str == 'END'
  #        send_data "Goodbye, dear!"
  #        close_connection
  #      else
  #        log.puts "RECEIVED #{received_str} SIZE #{received_str.size}"
  #      end
  #    end
  #
  #    def connection_completed
  #      log.puts "CONNECTION CLOSED"
  #    end
  #
  #    def unbind
  #      log.puts "ERROR"
  #    end
  #  end
  #
  #  Reactor.start(HOST, PORT, LoggerServer) do |connection|
  #    connection.log = STDOUT
  #  end
  #
  class Connection
    # Вместо хэндлера данных получает его object_id для избежания циклических ссылок
    # Доп. блок инициализации нужен, т.к. Connection инициализируется из хэндлера, а не при запуске сервера
    #
    # data_handler_id - Integer
    # initializer - блок инициализации
    #
    def initialize(data_handler_id, &initializer)
      @data_handler_id = data_handler_id
      initializer.call(self) if block_given?
    end

    # при чтении
    def receive_data(data)
    end

    # закрытии соединения
    def connection_completed
    end

    # при обрыве
    def unbind
    end

    protected

    def close_connection
      handler.close_connection
    end

    def send_data(data)
      handler.handle.print data
    end

    private

    def handler
      ObjectSpace._id2ref(@data_handler_id)
    end
  end
end