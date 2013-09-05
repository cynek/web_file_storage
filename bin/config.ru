require '../lib/rack/handler/file_server'
require '../lib/app/sinatra_app'

Rack::Handler::FileServerHandler.run SinatraApp.new
