require "sleepy_penguin/sp"
require "socket"
require File.dirname(__FILE__) + '/reactor/dispatcher'
require File.dirname(__FILE__) + '/reactor/event_handler'
require File.dirname(__FILE__) + '/reactor/acceptance_handler'
require File.dirname(__FILE__) + '/reactor/data_handler'
require File.dirname(__FILE__) + '/reactor/connection'

module Reactor
  WORKERS_COUNT = 2
  attr_reader :listener, :workers_count

  class << self
    # Запуск TCP сервера
    #
    # host - String
    # port - Integer
    # connection_handler_class - Class реализующий интерфейс Connection для управления подключением
    # workers_count - Integer количество воркеров
    # initialize - блок инициализации connection_handler'а
    #
    # Examples:
    #
    #   Reactor.start(HOST, PORT, LoggerServer, 5) do |connection|
    #     connection.log = STDOUT
    #   end
    #
    def start(host, port, connection_handler_class = Connection, workers_count = WORKERS_COUNT, &initializer)
      listener = TCPServer.new(host, port)

      workers_count.times do
        fork_connection(listener, connection_handler_class, &initializer)
      end

      Process.waitall
      listener.close
    end

    private

    def fork_connection(listener, connection_handler_class, &initializer)
      Process.fork do
        accept_handler = AcceptanceHandler.new(listener, connection_handler_class, &initializer)

        while accept_handler.running?
          Reactor::Dispatcher.instance.handle_events
        end
      end
    end
  end
end