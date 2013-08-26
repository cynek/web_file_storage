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
      @epoll.add(master_socket, SP::Epoll::OUT)

      pid = Process.fork do
        master_socket.close
        WorkerReader.new(worker_socket)
      end
      worker_socket.close

      WorkerWriter.new(master_socket, pid)
    end
  end

  # Public: Быстро отправляет дескриптор запроса воркеру и возвращает контекст
  #
  # connect_fd - Integer дескриптор соединения
  #
  # Returns true, false - если все воркеры заняты
  def work(connect_fd)
    worker = get_ready_worker
    return false if worker.nil?
    worker.send! connect_fd
  end

  private

  # Private: Найти свободный (готовый читать) воркер
  #
  # Returns Worker
  def get_ready_worker
    @epoll.wait do |_, socket|
      worker = workers.detect {|w| w.socket.fileno == socket.fileno }
      return worker unless worker.nil?
    end
  end
end