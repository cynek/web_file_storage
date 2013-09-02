# encoding : utf-8

Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/parser', '*.rb')].each { |file| require file }
Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/rack/handler', '*.rb')].each { |file| require file }

require 'rubygems'
require 'rack'

class FileApp

  def call(env)
    puts "process #{Process.pid} \nenv: #{env}"
    request = Parser.parse(env[:socket])
    #TODO приложение для отправки файлов в body
    [200, {'Content-Type' => ['text/html; charset=utf-8']}, ['get from rack!']]
  end

end
 
Rack::Handler::ServerHandler.run FileApp.new
