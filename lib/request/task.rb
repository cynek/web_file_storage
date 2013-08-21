# encoding : utf-8

class Task
  # базовый класс для SendTask и ReceiveTask

  def initialize(socket)
    @socket = socket
    yield(self)
  end
end # class Task
