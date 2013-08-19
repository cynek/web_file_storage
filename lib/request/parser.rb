require './socket_utils'
require './request'

module RequestBuilder
  class Parser
    GET = "GET"
    POST = "POST"
    ACCEPT_METHODS = [GET, POST]
    # парсер будет считывать данные из сокета
    # определяет тип запроса, заголовки, передаёт сокет дальше
    # TODO rspec
    include SocketUtils

    def parse(socket) # парсим данные в socket          
      raise "Connection not established" unless socket

      request_method, uri, protocol =  parse_request(socket)     
      raise "405 method #{request_method} not allowed" unless ACCEPT_METHODS.include? request_method 
      headers = parse_headers(socket)
      
      # создаём запрос в зависимости от метода
      case request_method
      when GET
        # создаём RequestSend
        request = RequestSend.new do |request|
          request.socket = socket
          request.file_path = uri
          request.seek_position = 0 # todo seek position        
        end
      when POST
        # создаём RequestReceive
        request = RequestReceive.new do |request|
          request.socket = socket
          request.content_length = headers['content-length'][0].to_i
          request.boundary = header_value( 'boundary', headers['content-type'] )
        end
      end      
    end

    private

    def parse_request(socket) # определить метод, URI и протокол
      request_line = read_line(socket)
      raise "bad request line" unless request_line

      if /^(\S+)\s+(\/\S+)\s+(\S+)$/ =~ request_line    
        [$1, $2, $3]
      else
        rl = request_line.sub(/\r?\n\z/, '')
        raise "bad request line `#{rl}'"
      end
    end

    def header_value(name, header)
      # получить значение ключа по имени из составного заголовка
      # типа [multipart/form-data; boundary="Asrf456BGe4h"]
      header.each do |line|
        if /^.*#{name}=(.*[^;$])$/o =~ line
          return $1
        end 
      end
    end

    def parse_headers(socket) # парсим заголовки     
      raw_header = []
      while line = read_line(socket)
        break if /\A\r?\n\z/ =~ line
        raw_header << line
      end

      header = Hash.new([].freeze)
      name = nil
      raw_header.each do |line|
        case line
        when /^([A-Za-z0-9!\#$%&'*+\-.^_`|~]+):\s*(.*?)\s*\z/m
          name, value = $1.downcase, $2
          header[name] = [] unless header.has_key?(name)
          header[name] << value
        when /^\s+(.*?)\s*\z/m
          value = $1
          unless name
            raise "bad header '#{line}'"
          end
          header[name][-1] << " " << value
        else
          raise "bad header '#{line}'"
        end
      end

      header.each do |key, values|
        values.each do |value|
          value.strip!
          value.gsub!(/\s+/, " ")
        end
      end

      header
    end
  end # class Parser
end # module RequestBuilder

# test case
parser = RequestBuilder::Parser.new

File.open('examples/http_post.txt', 'r') do |file| 
  request = parser.parse(file)
  puts request.class
  puts request.content_length
  puts request.boundary
end

3.times { puts }

File.open('examples/http_get.txt', 'r') do |file|
  request = parser.parse(file)
  puts request.class
  puts request.file_path
  puts request.seek_position
end

