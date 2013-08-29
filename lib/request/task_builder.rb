# encoding : utf-8

module TaskBuilder
  class TaskBuilder
    include Parser

    def initialize(socket)
      @socket = socket
    end

    def prepare
      request_method, uri, headers = Parser.parse(@socket)
    end

  end # class TaskBuilder
end # module TaskBuilder
