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