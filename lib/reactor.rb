require "sleepy_penguin/sp"
require File.expand_path 'reactor/dispatcher', File.dirname(__FILE__)
require File.expand_path 'reactor/event_handler', File.dirname(__FILE__)
require File.expand_path 'reactor/acceptance_handler', File.dirname(__FILE__)
require File.expand_path 'reactor/data_handler', File.dirname(__FILE__)
require File.expand_path 'reactor/connection', File.dirname(__FILE__)

module Reactor
  WORKERS_COUNT = 1
  attr_reader :listener, :workers_count

  class << self
    def start(host, port, connection_class, workers_count = WORKERS_COUNT)
      listener = TCPServer.new(host, port)

      workers_count.times do
        fork_connection(listener, connection_class)
      end

      Process.waitall
      listener.close
    end

    def fork_connection(listener, connection_class)
      Process.fork do
        acceptor = Reactor::AcceptanceHandler.new(listener, connection_class)

        loop do
          break if acceptor.stop_loop?
          Reactor::Dispatcher.instance.handle_events
        end
      end
    end
  end
end