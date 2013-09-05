# encoding : utf-8

#require 'socket'
#require File.expand_path '../../server', File.dirname(__FILE__)
require 'eventmachine'
require 'stringio'

module Rack
  module Handler
    module ServerHandler
      #include Server

      DEFAULT_OPTIONS = {
        :host => 'localhost',
        :port => 8080,
        :workers_count => 2
      }

      def self.run(app, options = {})
        options = DEFAULT_OPTIONS.merge(options)

        EventMachine.run do
          EventMachine.start_server("localhost", 8080, FileServer) do |connection|
            connection.app = app
          end
        end

      end
    end # module ServerHandler
  end # module Handler
end


class FileServer < EventMachine::Connection
  attr_accessor :app

   def post_init
     puts "-- someone connected to the echo server!"
   end

   def receive_data data


     socket = StringIO.new(data + "\r\nASDASDDASDASD")
     env = {}
     env[:socket] = socket
     status, headers, body = @app.call(env)    

     send_data "HTTP/1.1 #{status} OK\r\n"
     send_data headers
     send_data "\r\n"

     body.each { |part| send_data part.read }

     close_connection_after_writing
   end

   def unbind
     puts "-- someone disconnected from the echo server!"
   end

end
