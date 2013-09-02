# encoding : utf-8

require 'socket'
require File.expand_path '../../server', File.dirname(__FILE__)

module Rack
  module Handler
    module ServerHandler
      include Server

      DEFAULT_OPTIONS = {
        :host => 'localhost',
        :port => 8080,
        :workers_count => 2
      }

      def self.run(app, options = {})
        options = DEFAULT_OPTIONS.merge(options)

        listener = TCPServer.new(options[:host], options[:port])

        puts "WebFileServer starting..."
        puts "* Listening on tcp://#{options[:host]}:#{options[:port]}"
  
        options[:workers_count].times do
          fork do
            ServerHandler::AcceptanceHandler.new(listener, app, options)
            loop do
              ServerHandler::InitiationDispatcher.instance.handle_events
            end
          end
        end

        Process.waitall
        listener.close
      end
    end # module ServerHandler
  end # module Handler
end
