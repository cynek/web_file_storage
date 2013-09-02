# encoding : utf-8

module Reactor
  class Connection
    def initialize(handler_id)
      @handler_id = handler_id
    end

    def receive_data(data)
    end

    def connection_completed
    end

    protected

    def close_connection
      handler.close_connection
    end

    def send_data(data)
      handler.print data
    end

    private

    attr_reader :socket

    def handler
      ObjectSpace._id2ref(@handler_id)
    end
  end
end