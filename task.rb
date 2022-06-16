# Подключим встроенный в Ruby класс Date для работы с датами
require 'date'

class Task < Post

  # Определим конструктор класса
  def initialize
    # Вызовем конструктор родительского класса
    super
    # Дополнительно инициализируем специфичное для этого класса поле
    @due_date = Time.now
  end

  # Метод для считывания ввода от пользователя и записи его в нужные поля объекта
  def read_from_console
    # Будет переопределять родительский метод
  end

  # Метод для подготовки данных и возврата состояния объекта в виде массива строк для записи в файл
  def to_strings
    # Будет переопределять родительский метод
  end
end