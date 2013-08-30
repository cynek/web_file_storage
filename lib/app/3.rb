class AppBase

  @@handlers = {}

  def initialize request
    method, @uri, @headers, @socket = request
    @path = @uri
    method_handler = self.class.get_handler(method, @path)  
    if method_handler
      method_handler.call
    else
      puts "Method #{method} on path #{@path} not implemented"
    end
  end

  def self.get_handler(method, path) 
    @@handlers[method].keys.detect do |handler_path| 
      return @@handlers[method][handler_path] if path.match(handler_path)
    end   
  end

protected

  def self.register_method(method, path, &block)
    @@handlers[method] = {} unless @@handlers.key? method
    @@handlers[method][%r(#{path})] = block
  end

end

class App < AppBase
  register_method('get', 'stats')         { |path| puts "TO DO get #{path}" }
  register_method('get', '^/files/(.*)')  { |path| puts "TO DO get #{path}" }
  register_method('post', '^/files/(.*)') { |path| puts "TO DO post #{path}" }
end

request = ['get', '/sadasdas', {}, nil]
app = App.new(request)

request = ['get', '/files/123.txt', {}, nil]
app = App.new(request)

request = ['post', '/files/123.txt', {}, nil]
app = App.new(request)






