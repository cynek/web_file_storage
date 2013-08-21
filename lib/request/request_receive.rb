# encoding : utf-8
require './request'

class RequestReceive < Request
  # класс запроса на закачку файлов на сервер
  attr_accessor :content_length, # объем данных
                :boundary        # разделитель файлов
end # class RequestReceive
