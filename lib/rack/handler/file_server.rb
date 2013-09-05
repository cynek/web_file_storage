# encoding : utf-8
require '../lib/server/file_server'

module Rack
  module Handler
    module FileServerHandler
      include FileServer

      DEFAULT_OPTIONS = {
        :Host => 'localhost',
        :Port => 8080,
        :workers_count => 2
      }

      def self.run(app, options = {})
        options = DEFAULT_OPTIONS.merge(options)
        puts "Server start on #{options[:Host]}:#{options[:Port]}"

        EventMachine.run do
          EventMachine.start_server(options[:Host], options[:Port], FileServer) do |connection|
            connection.app = app
          end
        end

      end
    end # module ServerHandler
  end # module Handler
end
