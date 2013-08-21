# encoding : utf-8
require 'socket'
require "sleepy_penguin/sp"

class WorkerManager
  attr_reader :workers, :epoll

  def initialize(workers_counts)
    @epoll = SP::Epoll.new
    @workers = Array.new(workers_counts) do
      # create socket or pipe?
      master_socket, worker_socket = Socket.pair(:UNIX, :DGRAM, 0)
      @epoll.add(worker_socket, SP::Epoll::IN | SP::Epoll::ET)

      pid = Process.fork do
        master_socket.close
        WorkerReader.new(worker_socket)
      end

      WorkerWriter.new(master_socket, pid)
    end
  end

  # Public: Быстро отправляет запрос воркеру и возвращает контекст
  #
  # socket - TCPSocket
  #
  # Returns true, false - если все воркеры заняты
  def work(socket)
    worker = get_ready_worker
    worker.send! socket
  end

  private

  # Private: Найти и инстанциировать свободный (готовый читать) воркер
  #
  # Returns Worker
  def get_ready_worker

  end
end