require "socket"
$:.unshift File.dirname(__FILE__)

require 'reactor/dispatcher'
require 'reactor/event_handler'
require 'reactor/acceptance_handler'
require 'reactor/data_handler'
require 'reactor/manager'

module Reactor
  WORKERS_COUNT = 2

  class << self
    # Запуск TCP сервера
    #
    # @param host [String]
    # @param port [Integer]
    # @param data_handler_class [Class] подкласс DataHandler для получения/обработки данных
    # @param workers_count [Integer] количество воркеров
    # @yield [handler] блок инициализации DataHandler'а
    #
    # @example:
    #
    #    class Connection < Reactor::DataHandler
    #      attr_accessor :app, :request
    #
    #      def before_init
    #        @request = Request.new
    #        @response = Response.new
    #      end
    #
    #      def receive_data(data)
    #        process if @request.parse(data)
    #      rescue InvalidRequest => e
    #        close_connection
    #      end
    #
    #      def process
    #        @response.status, @response.headers, @response.body = *@app.call(@request.env)
    #        @response.each do |chunk|
    #          send_data chunk
    #        end
    #        close_connection
    #      end
    #    end
    #
    #    Reactor.start(HOST, PORT, Connection, 5) do |handler|
    #      handler.app = @app
    #    end
    #
    def start(host, port, data_handler_class = DataHandler, workers_count = WORKERS_COUNT, &initializer)
      listener = TCPServer.new(host, port)

      workers_count.times do
        fork_connection(listener, data_handler_class, &initializer)
      end

      Process.waitall
      listener.close
    end

    private

    def fork_connection(listener, data_handler_class, &initializer)
      Process.fork do
        dispatcher = Dispatcher.new

        # инициализируем принимающий подключения хэндлер
        AcceptanceHandler.new(listener, Manager.new(dispatcher, data_handler_class, &initializer))

        # запускаем цикл обработки событий
        dispatcher.run
      end
    end
  end
end