# Подключаем гем для работы с БД
require 'sqlite3'

# Создадим базовый (родительский) класс "Запись"
# Этот класс задает основные методы и свойства, присущие всем разновидностям записей
class Post

  # Определим статическое поле класса с названием БД
  @@SQLITE_DB_FILE = "notepad.sqlite"

  # Определим статический метод для отображения пользователю вариантов создоваемых записей
  # Так как теперь мы работаем с БД, поэтому удобнее иметь связь между классом и его именем
  def self.post_types
    { "Memo" => Memo, "Task" => Task, "Link" => Link }
  end

  # Определим метод для создания записи определенного вида (создания объекта дочернего класса)
  def self.create(type)
    return post_types[type].new
  end

  # Конструктор
  def initialize
    @created_at = Time.now # Дата создания записи
    @text = nil # Массив строк для записи в файл (пока пустой)
  end

  # Определим методы экземпляра класса
  # Метод для считывания ввода от пользователя и записи его в нужные поля объекта
  def read_from_console
    # Абстрактный метод; будет реализован в классах-потомках
  end

  # Метод для подготовки данных и возврата состояния объекта в виде массива строк для записи в файл
  def to_strings
    # Абстрактный метод; будет реализован в классах-потомках
  end

  # Метод для получения хэша и сохранения в БД новой записи
  def to_db_hash
    # Заполняем общие для всех классов поля
    {
      "type" => self.class.name, #self - указывает на "этот объект"
      "created_at" => @created_at.to_s
    }
    # Остальные поля дополнят дочерние классы сами
  end

  # Метод для сохранения данных в БД
  def save_to_db
    # Открываем соединение с БД
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)

    # Настраиваем БД - результаты из нее будут преобразовываться в хэш
    db.results_as_hash = true

    # Выполняем запрос к БД на добавление новой записи - хэша, сформированного дочерним классом
    begin
      db.execute(
        "INSERT INTO posts (" +
          to_db_hash.keys.join(", ") + # все поля, которые будут заполняться в БД
          ")" +
          "VALUES (" +
          ("?," * to_db_hash.keys.size).chomp(",") + # значения полей через плейсхолдеры "?"
          ")",
        to_db_hash.values
      )
    rescue SQLite3::SQLException => error
      puts "Не удалось установить соединение с базой данных #{@@SQLITE_DB_FILE}."
      abort error.message
    end

    # Получаем row_id последней добавленной в таблицу записи
    insert_row_id = db.last_insert_row_id

    # Закрываем соединение
    db.close

    # Возвращаем идентификатор записи
    return insert_row_id
  end

  # Метод для наполнения объекта данными из базы данных
  def load_data(data_hash)
    @created_at = Time.parse(data_hash["created_at"])
    # Остальные поля дополнят дочерние классы сами
  end

  # Метод, который записывает текущее состояние объекта в файл
  def save
    file = File.new(file_path, "w:UTF-8")
    to_strings.each { |string| file.puts(string) }
    file.close
  end

  # Метод, возвращающий путь к файлу, куда нужно записать объект
  def file_path
    current_path = File.dirname(__FILE__)
    file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")
    "#{current_path}/#{file_name}"
  end

  # Метод для поиска записи в БД по id, типу или выбирает все записи
  def self.find(limit, type, id)

    # Определяем метод для получения данных из БД согласно указанным пользователем параметрам
    # Если поиск по id
    unless id.nil?
      # Вызываем метод поиска по id
      find_by_id(id)

      # Если поиск не по id (поиск всех записей)
    else
      # Вызываем метод поиска всех записей
      find_by_all(limit, type)
    end
  end

  # Метод для поиска записи в БД по id
  def self.find_by_id(id)

    # Открываем соединение с БД
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)

    # Настраиваем БД - результаты из нее будут преобразовываться в хэш
    db.results_as_hash = true

    # Выполняем запрос на поиск записи по id, который возвращает массив результатов
    begin
      result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)
    rescue SQLite3::SQLException => error
      puts "Не удалось установить соединение с базой данных #{@@SQLITE_DB_FILE}."
      abort error.message
    end

    # Получаем единственный результат (если вернулся массив)
    result = result[0] if result.is_a?(Array)
    db.close

    # Если результат пустой
    if result.empty?
      puts "Id #{id} не найден в базе данных."
      return nil
    else
      # Создаем экземпляр класса найденной записи
      post = create(result["type"])

      # Наполняем пост содержимым
      post.load_data(result)

      return post
    end
  end

  # Метод для поиска всех записей в БД
  def self.find_by_all(limit, type)

    # Открываем соединение с БД
    db = SQLite3::Database.open(@@SQLITE_DB_FILE)

    # Настраиваем БД - результаты из нее НЕ будут преобразовываться в хэш
    db.results_as_hash = false

    # Формируем запрос в БД с нужными условиями
    query = "SELECT rowid, * FROM posts "
    # Если задан тип для поиска, то добавляем условие в запрос
    query += "WHERE type = :type " unless type.nil?
    # Добавялем в запрос условие сортировки
    query += "ORDER by rowid DESC "
    # Если задан лимит, то добавляем условие в запрос
    query += "LIMIT :limit " unless limit.nil?

    # Готовим запрос к БД
    begin
      statement = db.prepare query
    rescue SQLite3::SQLException => error
      puts "Не удалось установить соединение с базой данных #{@@SQLITE_DB_FILE}."
      abort error.message
    end

    # Добавляем в запрос тип и лимит вместо плейсхолдеров :type и :limit
    statement.bind_param("type", type) unless type.nil?
    statement.bind_param("limit", limit) unless limit.nil?

    # Выполняем запрос
    result = statement.execute!
    statement.close
    db.close

    return result
  end

end