# encoding : utf-8

class WorkerWriter
  attr_reader :pid, :socket

  def initialize(socket, pid)
    @socket, @pid = socket, pid
  end

  # Public: Отправить соединение воркеру
  #
  # socket - Socket для записи в воркер
  #
  # Returns nothing
  def send!(socket)

  end
end