# encoding : utf-8
require 'socket'

class Master
  PORT = 80
  HOST = 'localhost'
  WORKERS_COUNT = 5

  def initialize(workers_count = WORKERS_COUNT)
    @manager = WorkerManager.new(workers_count)
    @listener = TCPServer.new(HOST, PORT)
    @parser = Parser.new
  end

  def listen
    loop do
      request = @parser.parse(@listener.accept)
      @manager.work request
    end
  end
end