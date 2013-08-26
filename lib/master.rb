# encoding : utf-8
require 'socket'

class Master
  PORT = 8080
  HOST = 'localhost'
  WORKERS_COUNT = 1

  def initialize(workers_count = WORKERS_COUNT)
    @manager = WorkerManager.new(workers_count)
    @listener = TCPServer.new(HOST, PORT)
  end

  def listen
    loop do
      @manager.work @listener.sysaccept
    end
  end
end