# Подключаем все наши классы
require_relative 'post.rb'
require_relative 'link.rb'
require_relative 'memo.rb'
require_relative 'task.rb'

# Знакомимся с пользователем
puts "Привет, я Ваш блокнот! Версия 2.0 (+SQLite)."
puts "Что бы Вы хотели записать?"

# Получаем варианты записей
choices = Post.post_types.keys

# Определяем выбор по умолчанию
choice = -1

# Показываем пользователю все варианты и получаем от него ответ
until choice >= 0 && choice <= choices.size
  choices.each_with_index do |type, index|
    puts "\t#{index}. #{type}"
  end
  choice = STDIN.gets.chomp.to_i
end

# Согласно выбору пользователя создаем объект определенного класса
entry = Post.create(choices[choice])

# Просим пользователя ввести определенные данные согласно его выбору
entry.read_from_console

# Сохраняем полученную информацию в файл
rowid = entry.save_to_db

puts "Ваша запись сохранена. Id записис - #{rowid}."