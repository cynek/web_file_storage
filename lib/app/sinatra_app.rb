# encoding : utf-8
require 'sinatra/base'

class SinatraApp < Sinatra::Base  
  # test Sinatra application
  get "/" do
    'This is Sinatra!'
  end

  get "/hello/:id" do |id|
    id
  end    
end
