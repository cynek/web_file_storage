# encoding : utf-8
require './task'

class ReceiveTask < Task
  # класс для закачки файлов на сервер
  attr_accessor :content_length, # объем данных
                :boundary        # разделитель файлов

  def execute
    # TODO сохранение файлов из сокета
  end
end # class RequestTask
