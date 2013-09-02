#!/usr/bin/env ruby
# encoding: utf-8
require 'socket'
require "sleepy_penguin/sp"
require File.expand_path "lib/reactor", File.dirname(__FILE__)
require File.expand_path "lib/file_connection", File.dirname(__FILE__)

PORT = 8080
HOST = 'localhost'


Reactor.start(HOST, PORT, FileConnection)