# encoding : utf-8

Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/parser', '*.rb')].each { |file| require file }
Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/rack/handler', '*.rb')].each { |file| require file }

require 'rubygems'
require 'rack'
 
class FileApp
  def call(env)
    puts "process #{Process.pid} \nenv: #{env}"

    request = Parser.parse(env[:socket])


    [200, request[:headers], ['get from rack!']]
  end

end
 
Rack::Handler::ServerHandler.run FileApp.new

