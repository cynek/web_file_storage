# encoding : utf-8

Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/parser', '*.rb')].each { |file| require file }
Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/rack/handler', '*.rb')].each { |file| require file }

require 'rack'
require 'sinatra'

class FileApp
  def call(env)
    puts "process #{Process.pid} \nenv: #{env}"
    request = Parser.parse(env[:socket])
    #TODO приложение для отправки файлов в body
    [200, request[:headers], [request[:socket]]]
  end
end

class SinatraApp < Sinatra::Base
  
  get '/' do
    'Hello world!'
  end

end

Rack::Handler::ServerHandler.run SinatraApp.new 
