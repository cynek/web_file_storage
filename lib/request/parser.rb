# encoding : utf-8

module Parser
  class Parser    
    # Parser возвращает request_method, uri, header полученные из io
    #
    # Example:
    #
    #  # socket: IO object
    #  # request_method: String
    #  # request_method: String
    #  # header: Hash
    #  request_method, uri, header = Parser::Parser.parse(socket)
    
    def self.parse(socket)
      # парсим данные, полученные в socket
      request_method, uri = parse_request_line(socket)
      headers = parse_headers(socket)
      return request_method, uri, headers
    end

    private

    class << self
      def parse_request_line(socket)
        # определить метод и URI
        request_line = socket.gets.chomp

        regex = %r[\A(?<request_method>\S+)\s+    # GET, POST, etc
                   (?<uri>\/\S+)\s+\S+]x          # URI & tail

        match_data = regex.match request_line 
        if match_data
          request_method = match_data[:request_method]
          uri = match_data[:uri]
        end

        [request_method, uri]
      end

      def parse_headers(socket)
        # парсим заголовки
        header = Hash.new { |h, k| h[k] = [] }
        
        empty_line = /\A\r?\n\z/
        header_regex = %r[^(?<header_name>[A-Za-z0-9!\#$%&'*+\-.^_`|~]+): # header name
                          \s*(?<header_value>.*?)\s*\z]x                  # header value
        
        loop do
          line = socket.gets
          break if empty_line.match(line) || line.nil?

          match_data = header_regex.match line 
          if match_data
            name = match_data[:header_name].chomp
            value = match_data[:header_value].chomp            
            header[name] << value
          end                 
        end

        header
      end
    end
  end # class Parser
end # module Parser
