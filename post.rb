# Создадим базовый (родительский) класс "Запись"
# Этот класс задает основные методы и свойства, присущие всем разновидностям записей
class Post
  # Определим конструктор класса
  def initialize
    @text = nil
    @created_at = Time.now
  end

  # Определим методы экземпляра класса
  # Метод для считывания ввода от пользователя и записи его в нужные поля объекта
  def read_from_console
    # Будет реализован в класса-потомках, которые знают как нужно считывать данные из консоли
  end

  # Метод для подготовки данных и возврата состояния объекта в виде массива строк для записи в файл
  def to_strings
    # Будет реализован в классах-потомках, которые знают, как сохранять данные в файл
  end

  # Метод, который записывает текущее состояние объекта в файл
  def save
    #to do
  end
end