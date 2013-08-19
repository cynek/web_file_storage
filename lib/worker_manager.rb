# encoding : utf-8

class WorkerManager
  # отображение типа запроса на воркер
  WORKER_CLASSES = {
      :file_receive => FileReceiver,
      :file_send    => FileSender
  }.freeze

  # Public: Инстанциирует указанное число воркеров соответствующих типу запроса
  #
  # workers_counts - Hash количества воркеров
  #                -
  #
  def initialize(workers_counts)
    @pids = {
        :file_receive => [],
        :file_send   =>  []
    }
    workers_counts.each do |request_type, count|
      count.times do
        pid = fork do
          WORKER_CLASSES[request_type].new
        end
        @pids[request_type] << pid
      end
    end
  end

  # Public: Быстро отправляет запрос воркеру и возвращает контест
  #
  # request - Request
  #
  # Returns true, false - если все воркеры заняты
  def work(request)
    worker = get_vacant_for request.type

    # отправить запрос
  end

  private

  def get_vacant_for(request_type)
  end

end