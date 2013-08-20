# encoding : utf-8

class Worker
  attr_reader :pid

  # Public: Отправить запрос воркеру
  #
  # request - Request
  #
  # Returns nothing
  def send!(request)

  end

  # Public: Принять запрос от мастера
  #
  # Returns Request
  def receive!

  end
end