module SocketUtils
  # функции для чтения и записи в сокет
  BUFFER_SIZE = 4096 # размер блока на считываение данных из IO

  ###############################
  ###    read socket utils    ###
  ###############################
  def read_line(socket, size = BUFFER_SIZE)
    # считать одну строку
    read_socket(socket, :gets, "\n", size)
  end
  
  def read_by_length(socket, length = BUFFER_SIZE)
    remaining_size = length
    data = ''
    while remaining_size > 0
      size = [BUFFER_SIZE, remaining_size].min
      break unless buf = read_block(socket, size)
      remaining_size -= buf.bytesize
      data += buf          
    end 

    data
  end

  ###############################
  ###   write socket utils    ###
  ###############################

  def send_file(socket, filename)
    #отправка файла
    File.open(filename, 'rb') do |file|
      while block = file.read(BUFFER_SIZE)
        socket.write block
      end
    end #File.open
  end
  
  def get_file(socket, filename)
    # запись в файл из сокета
    File.open(filename, 'w') do |file|
      while message = socket.read(BUFFER_SIZE)
        file.write
      end
    end #File.open
  end

  private

  def read_block(socket, size = BUFFER_SIZE)
    # считать блок данных
    read_socket(socket, :read, size)
  end

  def read_socket(socket, method, *args)
    #TODO таймаут на чтение из сокета
    return socket.send(method, *args)
  end

end # module SocketUtils
