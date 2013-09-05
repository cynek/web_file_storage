# encoding : utf-8
require 'eventmachine'
require 'stringio'
require '../lib/request/parser'

module FileServer 
  class FileServer < EventMachine::Connection
  # простой сервер на EventMachine для использования в Rack::Handler
  
    attr_accessor :app

    def post_init
      puts "-- someone connected to the server!"
    end

    def receive_data(data)
      # обработка соединения
      socket = StringIO.new(data)
      env = service(socket)
      status, headers, body = @app.call(env)

      case status
      when 200
        status_message = 'OK'
      when 404
        status_message = 'Not found :('
      end

      send_data "HTTP/1.0 #{status} #{status_message}\r\n"

      headers.each do |k,v|
        send_data "#{k}: #{v}\r\n"
      end
      send_data "\r\n"

      body.each { |part| send_data part }

      close_connection_after_writing
    end

    def service(socket)
      # подготавливаем env
      env = Hash.new      
      request = Parser.parse(socket)

      request[:headers].freeze
      headers = request[:headers].dup

      headers.each{|key, val|
        next if /^content-type$/i =~ key
        next if /^content-length$/i =~ key
        name = key.dup
        name.gsub!(/-/o, "_")
        name.upcase!
        env[name] = val
      }
     
      rack_input = request[:socket]
      rack_input.set_encoding(Encoding::BINARY) if rack_input.respond_to?(:set_encoding)

      env.update({"rack.version" => Rack::VERSION,
                   "rack.input" => [rack_input],
                   "rack.errors" => $stderr,
                 })

      env["REQUEST_METHOD"] = request[:request_method].dup
      env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
      env["HTTP_VERSION"] ||= 'HTTP/1.1'
      env["QUERY_STRING"] ||= ""
      env["PATH_INFO"] = request[:uri].dup
      env["REQUEST_PATH"] ||= [env["SCRIPT_NAME"], env["PATH_INFO"]].join  
      env
    end

    def unbind
      puts "-- someone disconnected from the server!"
    end

  end
end
