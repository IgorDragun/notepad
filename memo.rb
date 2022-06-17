class Memo < Post
  # Отдельного конструктора не будет, так как он совпадает с конструктором родительского класса

  # Метод для считывания ввода от пользователя и записи его в нужные поля объекта
  def read_from_console
    puts "Я сохраню всё, что Вы напишете до строчки \"end\" в файл:"
    line = nil

    while line != "end" do
      line = STDIN.gets.chomp
      @text << line
    end

    @text.pop
  end

  # Метод для подготовки данных и возврата состояния объекта в виде массива строк для записи в файл
  # Переопределяем метод родительского класса
  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d, %H:%M")}.\n\r"

    @text.unshift(time_string)
  end
end