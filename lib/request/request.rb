class Request
  # базовый класс для RequestSend и RequestReceive
  attr_accessor :socket

  def initialize
    yield(self)
  end
end # class Request

class RequestSend < Request
  # класс запроса на скачивание файла с сервера
  attr_accessor :file_path,     # путь к файлу  
                :seek_position  # смещение от начала файла для докачки
end # class RequestSend

class RequestReceive < Request
  # класс запроса на закачку файлов на сервер
  attr_accessor :content_length, # объем данных
                :boundary        # разделитель файлов
end # class RequestReceive
