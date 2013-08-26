# encoding : utf-8
require './socket_utils'
require './receive_task'
require './send_task'

module TaskCreator
# создаёт задачи для воркеров
  GET = 'GET'
  POST = 'POST'
  ACCEPT_METHODS = [GET, POST]

  Request = Struct.new(:request_method, :uri, :headers, :body)

  module TaskBuilder
    # = EXAMPLE
    #   request = Parser.parse(socket)
    #   task = TaskBuilder.create_task(request)
    #   task.execute
    module_function

    def create_task(request)
      case request.request_method
      when GET
        SendTask.new(request.body) do |task|
          task.file_path = request.uri
          range = header_value( 'bytes', request.headers.fetch('range', false) )

          if range
            range = range.split('-')
            if range[0] && range[1]
              raise 'Incorrect range' if range[0].to_i > range[1].to_i
            end

            task.seek_start = range[0].to_i
            task.seek_end = range[1].to_i
          end
        end
      when POST
        ReceiveTask.new(request.body) do |task|
          task.content_length = request.headers['content-length'][0].to_i
          task.boundary = header_value('boundary', request.headers.fetch('content-type'))
        end
      else
        raise 'Incorrect request'
      end
    end

    private

    module_function

      def header_value(name, header)
        # получить значение ключа по имени из составного заголовка
        # типа [multipart/form-data; boundary="Asrf456BGe4h"]
        return unless header

        value = nil
        header.each do |line|
          value = $1 if %r[^.*#{name}=(.*[^;$])$] =~ line # бага, если писать /^.*#{name}=(.*[^;$])$/o - глючит
        end

        value
      end

  end # module TaskBuilder

  module Parser
    # парсер будет считывать данные из сокета
    # определяет тип запроса, заголовки, передаёт сокет дальше
    # TODO rspec
    module_function

    def parse(socket) # парсим данные в socket
      raise 'Connection not established' unless socket

      request_method, uri, protocol =  parse_request(socket)
      raise "405 method #{request_method} not allowed" unless ACCEPT_METHODS.include? request_method
      headers = parse_headers(socket)
      Request.new(request_method, uri, headers, socket)
    end

    private

    class << self
      include SocketUtils

      def parse_request(socket) # определить метод, URI и протокол
        request_line = read_line(socket)
        raise 'bad request line' unless request_line

        if /^(?<request_method>\S+)\s+(?<uri>\/\S+)\s+(?<protocol>\S+)$/ =~ request_line
          [request_method, uri, protocol]
        else
          rl = request_line.sub(/\r?\n\z/, '')
          raise "bad request line `#{rl}'"
        end
      end

      def parse_headers(socket) # парсим заголовки
        raw_header = []

        loop do
          line = read_line(socket)
          break if /\A\r?\n\z/ =~ line || line.nil?
          raw_header << line
        end

        header = Hash.new { |h, k| h[k] = [] }
        name = nil

        raw_header.each do |line|
          case line
          when /^([A-Za-z0-9!\#$%&'*+\-.^_`|~]+):\s*(.*?)\s*\z/m
            name, value = $1.downcase, $2
            header[name] = [] unless header.key?(name)
            header[name] << value
          when /^\s+(.*?)\s*\z/m
            value = $1           
            raise "bad header '#{line}'" unless name
            header[name][-1] << ' ' << value
          else
            raise "bad header '#{line}'"
          end
        end

        header.each do |key, values|
          values.each do |value|
            value.strip!
            value.gsub!(/\s+/, ' ')
          end
        end

        header
      end
    end
  end # module Parser
end

# test case

File.open('examples/http_post.txt', 'r') do |file|
  request = TaskCreator::Parser.parse(file)
  task = TaskCreator::TaskBuilder.create_task(request)
  puts task.class
  puts task.content_length
  puts task.boundary
end

2.times { puts }

File.open('examples/http_get.txt', 'r') do |file|
  request = TaskCreator::Parser.parse(file)
  task = TaskCreator::TaskBuilder.create_task(request)
  puts task.class
  puts task.file_path
  puts task.seek_start
  puts task.seek_end
end
