# encoding : utf-8

module Server
  class EventHandler
    def handle_event
      raise NotImplementedError
    end

    def get_handle
      raise NotImplementedError
    end
  end
end