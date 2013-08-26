# encoding : utf-8
require './task'

class SendTask < Task
  # класс для скачивания файла с сервера
  attr_accessor :file_path,     # путь к файлу
                :seek_start,    # смещение от начала файла для докачки
                :seek_end       # конец диапазона считывания файла

  def execute
    # TODO запись файлов в сокет
    send_file(@socket, @file_path, @seek_start, @seek_end)
  end

end # class SendTask
