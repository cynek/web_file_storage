require "sleepy_penguin/sp"
require File.expand_path 'reactor/dispatcher', File.dirname(__FILE__)
require File.expand_path 'reactor/event_handler', File.dirname(__FILE__)
require File.expand_path 'reactor/acceptance_handler', File.dirname(__FILE__)
require File.expand_path 'reactor/data_handler', File.dirname(__FILE__)
require File.expand_path 'reactor/connection', File.dirname(__FILE__)

module Reactor
  WORKERS_COUNT = 2
  attr_reader :listener, :workers_count

  class << self
    # Запуск TCP сервера
    #
    # host - String
    # port - Integer
    # connection_handler_class - Class реализующий интерфейс Connection для управления подключением
    # &initialize - блок инициализации connection_handler'а
    #
    # Examples:
    #
    #   Reactor.start(HOST, PORT, FileServer, 5) do |connection|
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