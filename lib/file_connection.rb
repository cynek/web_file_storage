# encoding : utf-8
require File.expand_path 'reactor/connection', File.dirname(__FILE__)

class FileConnection < Reactor::Connection
  def receive_data(data)
    received_str = data.strip
    if received_str == 'END'
      close_connection
    else
      puts "RECEIVED #{received_str} SIZE #{received_str.size}"
    end
  end

  def need_data
    send_data "RECEIVED BY #{Process.pid}"
  end

  def connection_completed
    puts "CONNECTION CLOSED"
  end
end