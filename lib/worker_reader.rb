# encoding : utf-8

class WorkerReader
  attr_reader :socket

  def initialize(socket)
    @socket = socket
  end

  # Public: Принять соединение от мастера
  #
  # Returns Socket
  def receive!

  end
end