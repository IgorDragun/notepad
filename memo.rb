class Memo < Post
  # Отдельного конструктора не будет, так как он совпадает с конструктором родительского класса

  # Метод для считывания ввода от пользователя и записи его в нужные поля объекта
  def read_from_console
    puts "Я сохраню всё, что Вы напишете до строчки \"end\" в файл:"

    @text = []
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


  def to_db_hash
    # Получаем предзаполненных родительских классом хэш и добавляем туда значения дочернего класса
    return super.merge(
      {
        "text" => @text.join("\n\r") # Массив строк делаем одной большой строкой
      }
    )
  end


  # Метод для наполнения объекта данными из базы данных
  def load_data(data_hash)
    # Сперва вызываем родительский метод
    super(data_hash)

    # Затем наполняем свои специфичные поля
    @text = data_hash["text"].split("\n\r")
  end

end