# encoding : utf-8
require 'socket'

class Master < Process
  PORT = 80
  HOST = 'localhost'
  RECEIVERS_COUNT = 2
  SENDERS_COUNT = 2

  def initialize
    @manager = WorkerManager.new :file_receive => RECEIVERS_COUNT,
                                 :file_send    => SENDERS_COUNT
    @listener = TCPServer.new(HOST, PORT)
    listen
  end

  private

  def listen
    loop do
      request = Request.new(@listener.accept)
      1 until @manager.work request
    end
  end
end