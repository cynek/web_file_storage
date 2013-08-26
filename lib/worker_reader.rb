# encoding : utf-8

class WorkerReader
  FD_MAX_LENGTH = 10
  attr_reader :socket

  def initialize(socket)
    @socket = socket
    work!
  end

  def work!
    loop do
      connection = receive!
      p connection.remote_address if connection
    end
  end

  # Public: Принять соединение от мастера
  #
  # Returns Socket
  def receive!
    fd = @socket.recv(FD_MAX_LENGTH)
    Socket.for_fd(fd.to_i) unless fd.nil?
  end
end