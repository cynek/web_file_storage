#!/usr/bin/env ruby
# encoding: utf-8
require 'socket'
require "sleepy_penguin/sp"
require File.expand_path "lib/server", File.dirname(__FILE__)

PORT = 8080
HOST = 'localhost'
WORKERS_COUNT = 2

listener = TCPServer.new(HOST, PORT)

WORKERS_COUNT.times do
  fork do
    MyServer::AcceptanceHandler.new(listener)
    loop do
      MyServer::InitiationDispatcher.instance.handle_events
    end
  end
end

Process.waitall
listener.close
