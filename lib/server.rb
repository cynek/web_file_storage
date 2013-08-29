require "sleepy_penguin/sp"
require File.expand_path 'server/initiation_dispatcher', File.dirname(__FILE__)
require File.expand_path 'server/event_handler', File.dirname(__FILE__)
require File.expand_path 'server/acceptance_handler', File.dirname(__FILE__)
require File.expand_path 'server/read_handler', File.dirname(__FILE__)

module Server
  ACCEPT_EVENT  = 1.freeze
  READ_EVENT    = 2.freeze
  WRITE_EVENT   = 4.freeze
  TIMEOUT_EVENT = 8.freeze
  CLOSE_EVENT   = 16.freeze
end