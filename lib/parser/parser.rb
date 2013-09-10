# encoding : utf-8
#
# parser.rb
#

require '../lib/parser/request_parser.tab'

module Parser
  # ошибка парсинга запроса
  class RequestError < StandardError
    # вернуть клиенту 400 Bad request
    def message
      '400 Bad request!'
    end
  end

  # Parser.parse формирует @env при получении данных (похожий на Rack::Request)
  #
  # == Example:
  #  parser = Parser.new
  #
  #  # ... while receive data
  #  loop
  #    data = socket.gets.strip
  #    break if parser.parse(data)
  #  end
  #  request = parser.env
  #
  #  #request["REQUEST_METHOD"] - HTTP action
  #  #request["URI"] - запрошенный URI
  #  #request["PROTOCOL"] - протокол запроса
  #  #request["#{header_name}"] - значение заголовка "#{header_name}"
  class Parser
    START_KEYS = %w(REQUEST_METHOD URI PROTOCOL)
    EMPTY_STRING = /^$/

    attr_reader :env

    def initialize
      @env = {}
    end

    # парсим данные, полученные в data и добавляем в @env
    # == Parameters
    #  data::
    #    Строка, полученная при чтении данных запроса из сокета
    #    
    # == Returns:
    #  True, если на вход поступила пустая строка (чтение заголовков завершено, хеш @env сформирован)
    #  False, если чтение заголовков не завершено
    def parse(data)
      return true if data =~ EMPTY_STRING

      parser = RequestParser.new
      header = parser.scan_str(data)
      merge_parsed header
      false
    rescue ParseError
      raise RequestError
    end

    private

    # распарсенные данные добавляются в @env
    def merge_parsed(data)
      validate_first_line data if @env.empty?

      @env.merge!(data) do |key, oldval, newval|      
        hold_request_line key

        # если заголовок встречается повторно, то формируется массив значений
        if oldval.kind_of?(Array)
          oldval.push newval
        else
          newval = [oldval, newval]
        end
      end
    end

    # вызвать исключение, если после первого прохода парсера нет данных о запросе
    def validate_first_line(data)
      START_KEYS.each { |key| raise RequestError unless data.key?(key) }
    end

    # вызвать исключение при переопределении request_method, uri или protocol
    def hold_request_line(key)
      raise RequestError if START_KEYS.include? key
    end

  end # class Parser
end # module Parser


