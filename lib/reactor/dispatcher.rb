# encoding : utf-8
require 'set'
require "sleepy_penguin/sp"

module Reactor
  # Регистриует и уведомляет обработчики событий
  #
  # @example
  #
  #    socket = TCPServer.new('localhost', 8080)
  #    reactor = Reactor::Dispatcher.new
  #
  #    reactor.read(socket) do |socket|
  #      connection = socket.accept_nonblock
  #
  #      reactor.read(connection) do |connection|
  #        puts connection.gets
  #        reactor.remove_handler_event(connection, :read)
  #        connection.close
  #      end
  #
  #      reactor.write(connection) do |connection|
  #        connection.puts Process.pid.to_s
  #        reactor.remove_handler_event(connection, :write)
  #      end
  #    end
  #    reactor.run
  #
  class Dispatcher
    CALLBACK_EVENTS = {
      :read    => SP::Epoll::IN,
      :write   => SP::Epoll::OUT,
      :error   => SP::Epoll::ERR,
      :hangup  => SP::Epoll::HUP
    }

    def initialize
      @running = false
      @handlers = Hash.new do |handlers, io|
        handlers[io] = {
          SP::Epoll::IN  => nil,
          SP::Epoll::OUT => nil,
          SP::Epoll::ERR => nil,
          SP::Epoll::HUP => nil
        }
      end

      @epoll = SP::Epoll.new
    end

    CALLBACK_EVENTS.each do |callback, event|
      # Методы регистрации обработчиков :read, :write, :error, :hangup
      # При повторном вызове предыдущий обработчик заменяется новым
      #
      # @param io [IO]
      # @param handler [Proc]
      #
      # @example чтение
      #
      #   reactor.read(io) do |io|
      #     io.gets
      #   end
      #
      define_method(callback) do |io, &handler|
        # включаем наблюдение
        enable_event_for(event, io)

        # заполняем список подписчиков
        @handlers[io][event] = handler
      end
    end

    def running?
      @running
    end

    # Главный цикл обработки событий
    #
    def run
      raise RuntimeError, "already running" if running?
      @running = true

      while running?
        handle_events
      end
    ensure
      @handlers.keys.each do |io|
        io.close
      end
      @handlers.clear
      @running = false
    end

    # Удалить обработчик события
    #
    # @param io [IO]
    # @param callback [Symbol] имя обработчика (:read, :write, :error, :hangup)
    #
    def remove_handler_event(io, callback)
      # исключаем из подписчиков
      @handlers[io].delete callback

      # отключаем наблюдение
      disable_event_for(CALLBACK_EVENTS[callback], io)
    end

    # Обработка событий
    def handle_events
      @epoll.wait do |event, io|
        @handlers[io][event].call io
      end
    end

    private

    # Включает наблюдение за событием IO
    #
    # @param event [Integer] Epoll event
    # @param io [IO]
    #
    def enable_event_for(event, io)
      if @handlers.include?(io)
        @epoll.mod(io, @epoll.events_for(io) | event)
      else
        @epoll.add(io, event)
      end
    end

    # Отключает наблюдение события IO
    #
    # @param event [Integer]
    # @param io [IO]
    #
    def disable_event_for(event, io)
      # полностью отключаем наблюдение за IO, если подписчиков на нем больше нет
      if @handlers[io].empty?
        disable_all_for(io)
      # иначе отключаем наблюдение только за этим событием
      else
        @epoll.mod(io, @epoll.events_for(io) & ~event)
      end
    end

    # Отключает наблюдение за IO
    #
    # @param io [IO]
    #
    def disable_all_for(io)
      @handlers.delete(io)
      @epoll.del(io)
    end
  end
end