# encoding : utf-8
require './request'

class RequestSend < Request
  # класс запроса на скачивание файла с сервера
  attr_accessor :file_path,     # путь к файлу  
                :seek_start,    # смещение от начала файла для докачки
                :seek_end       # конец диапазона считывания файла
end # class RequestSend
