# encoding : utf-8
require 'pp'
require '../lib/parser'

parser = Parser::Parser.new
File.readlines('http_get.txt').each do |line|
  break if parser.parse(line.strip)
end

request = parser.env
puts request.pretty_inspect
