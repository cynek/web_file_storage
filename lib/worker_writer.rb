# encoding : utf-8

class WorkerWriter
  attr_reader :pid, :socket

  def initialize(socket, pid)
    @socket, @pid = socket, pid
  end

  # Public: Отправить соединение воркеру
  #
  # fd - Integer дескриптор соединения для записи в воркер
  #
  # Returns nothing
  def send!(fd)
    @socket.send(fd.to_s, 0)
  end
end