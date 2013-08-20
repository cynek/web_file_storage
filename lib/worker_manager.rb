# encoding : utf-8

class WorkerManager
  attr_reader :pids

  def initialize(workers_counts)
    @pids = Array.new(workers_counts) do
      Process.fork do
        Worker.new
      end
    end
  end

  # Public: Быстро отправляет запрос воркеру и возвращает контест
  #
  # request - Request
  #
  # Returns true, false - если все воркеры заняты
  def work(request)
    worker = get_ready_worker
    worker.send! request
  end

  private

  # Private: Найти и инстанциировать свободный (готовый читать) воркер
  #
  # Returns Worker
  def get_ready_worker

  end
end