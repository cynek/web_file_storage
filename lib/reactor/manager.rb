# encoding : utf-8

# Хранит данные о диспетчере, подклассе и инициализаторе DataHandler'а
class Manager
  attr_accessor :dispatcher, :data_handler_class, :initializer
  def initialize(dispatcher, data_handler_class, &initializer)
    @dispatcher = dispatcher
    @data_handler_class = data_handler_class
    @initializer = initializer
  end
end