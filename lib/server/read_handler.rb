# encoding : utf-8
Dir[File.join("#{File.dirname(__FILE__)}", '', '*.rb')].each { |file| require file }

module Server
  class ReadHandler < EventHandler
    def initialize(connection_socket, app, env)
      @app = app
      @env = env
      @connection = connection_socket
      InitiationDispatcher.instance.register_handler(self, [SP::Epoll::IN, SP::Epoll::ET])
    end

    def get_handle
      @connection
    end

    def handle_event(event)
      case event
        when SP::Epoll::IN      
          @env[:socket] = @connection
          status, headers, body = @app.call(@env)

          $stdout.print "Status: #{status}\r\n"
            headers.each do |k, vs|
            vs.each do |v|
              $stdout.print "#{k}: #{v}\r\n"
            end
          end

          body.each do |part|
            $stdout.print part
            $stdout.flush
          end


#          received_str = (@connection.recv(255)).strip
#          if received_str == 'END'
#            InitiationDispatcher.instance.remove_handler self, SP::Epoll::IN
#            InitiationDispatcher.instance.remove_handler self, SP::Epoll::ET
#            @connection.close
#          else
#            puts "RECEIVED #{received_str} SIZE #{received_str.size}"
#          end
        when SP::Epoll::OUT
        # TODO: разобраться почему блокируется ввод при этом событии
          #@connection.puts "RECEIVED BY #{Process.pid}"
      end
    end
  end
end
