# Подключаем все наши классы
require_relative 'post.rb'
require_relative 'link.rb'
require_relative 'memo.rb'
require_relative 'task.rb'

# Подключаем библиотеку для обработки параметров командной строки
require 'optparse'

# Объявляем переменную, куда запишем все наши опции
options = {}

# Заводим нужные нам опции
OptionParser.new do |opt|
  opt.banner = "Usage: read.rb[options]"

  opt.on("-h", "Prints this help") do
    puts opt
    exit
  end

  opt.on("--type POST_TYPE", "какой тип постов показывать (по умолчанию - любой)"){|o| options[:type] = o}
  opt.on("--id POST_ID", "если задан id - показываем подробно только этот пост"){|o| options[:id] = o}
  opt.on("--limit NUMBER", "сколько последний постов показать (по умолчанию - все)"){|o| options[:limit] = o}

end.parse!

result = Post.find(options[:limit], options[:type], options[:id])

# Если в результате поиска получили класс Post, то показываем конкретный пост
if result.is_a?(Post)
  puts "Запись #{result.class.name}, id = #{options[:id]}"

  # Выводим на экран весь пост и закрываемся
  result.to_strings.each do |line|
    puts line
  end

# Иначе показываем тиблице результатов
else
  print "| id\t| @type\t| @created_at\t\t\t| @text\t\t\t| @url\t\t| @due_date \t"

  result.each do |row|
    puts

    row.each do |element|
      print "| #{element.to_s.delete("\n\r")[0..40]}\t"
    end
  end
end

puts