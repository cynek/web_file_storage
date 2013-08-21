# encoding : utf-8
require 'socket'

class Master
  PORT = 80
  HOST = 'localhost'
  WORKERS_COUNT = 5

  def initialize(workers_count = WORKERS_COUNT)
    @manager = WorkerManager.new(workers_count)
    @listener = TCPServer.new(HOST, PORT)
  end

  def listen
    loop do
      @manager.work @listener.accept
    end
  end
end