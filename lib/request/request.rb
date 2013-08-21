# encoding : utf-8

class Request
  # базовый класс для RequestSend и RequestReceive
  attr_accessor :socket

  def initialize
    yield(self)
  end
end # class Request
