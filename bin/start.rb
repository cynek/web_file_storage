# encoding : utf-8

Dir[File.join("../#{File.dirname(__FILE__)}", 'lib/request', '*.rb')].each { |file| require file }

puts 'Check parser:'
puts
File.open('../examples/http_post.txt', 'r') do |file|
  puts Parser.parse(file)
end

puts

File.open('../examples/http_get.txt', 'r') do |file|
  puts Parser.parse(file)
end

puts

