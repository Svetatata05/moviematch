# db/seeds.rb
puts "Очищення бази..."
Comment.destroy_all
Rating.destroy_all
Watchlist.destroy_all
Movie.destroy_all
User.destroy_all

puts "Створення користувача..."
User.create!(
  name: "Тестовий користувач",
  email: "test@example.com",
  password: "password123"
)

puts "Створення фільмів..."
movies = [
  { title: "Початок", genre: "Sci-Fi", rating: 8.8, runtime: 148,
    release_date: "2010-07-16", director: "Крістофер Нолан", media_type: "movie",
    original_title: "Inception", original_language: "en", tagline: "Your mind is the scene of the crime.",
    status: "Released", trailer_key: "YoHD9XEInc0", content_rating: "PG-13",
    description: "Злодій, який краде корпоративні секрети через технологію обміну снами, отримує зворотне завдання — вкласти ідею." },
  { title: "Темний лицар", genre: "Action", rating: 9.0, runtime: 152,
    release_date: "2008-07-18", director: "Крістофер Нолан", media_type: "movie",
    original_title: "The Dark Knight", original_language: "en", trailer_key: "EXeTwQWrcwY", content_rating: "PG-13",
    description: "Бетмен стикається з Джокером — злочинцем, який сіє хаос у Готем-Сіті." },
  { title: "Інтерстеллар", genre: "Sci-Fi", rating: 8.6, runtime: 169,
    release_date: "2014-11-07", director: "Крістофер Нолан", media_type: "movie",
    original_title: "Interstellar", original_language: "en", trailer_key: "zSWdZVtXT7E", content_rating: "PG-13",
    description: "Команда астронавтів подорожує через черв'яну нору в пошуках нового дому для людства." },
  { title: "Пітьма", genre: "Sci-Fi, Drama", rating: 8.4, runtime: 53,
    release_date: "2017-12-01", director: "Баран бо Одар, Янтьє Фрізе", media_type: "tv",
    original_title: "Dark", original_language: "de", trailer_key: "rrwycJ08PSA", content_rating: "TV-MA",
    status: "Ended", description: "Зникнення дитини змушує чотири родини розкрити таємниці маленького німецького містечка." },
  { title: "Дивні дива", genre: "Drama, Sci-Fi", rating: 8.6, runtime: 50,
    release_date: "2016-07-15", director: "Брати Даффер", media_type: "tv",
    original_title: "Stranger Things", original_language: "en", trailer_key: "b9EkMc79ZSU", content_rating: "TV-14",
    status: "Returning Series", description: "Друзі, родини й надприродні сили стикаються після зникнення хлопчика в маленькому містечку." },
  { title: "Список Шиндлера", genre: "Drama", rating: 8.9, runtime: 195,
    release_date: "1993-12-15", director: "Стівен Спілберг", media_type: "movie",
    description: "Справжня історія Оскара Шиндлера, який врятував понад тисячу євреїв під час Голокосту." },
  { title: "Бійцівський клуб", genre: "Drama", rating: 8.8, runtime: 139,
    release_date: "1999-10-15", director: "Девід Фінчер",
    description: "Незадоволений клерк і мило продавець заснували підпільний бійцівський клуб." },
  { title: "Матриця", genre: "Sci-Fi", rating: 8.7, runtime: 136,
    release_date: "1999-03-31", director: "Вачовскі",
    description: "Комп'ютерний хакер дізнається про справжню природу реальності." },
  { title: "Форрест Гамп", genre: "Drama", rating: 8.8, runtime: 142,
    release_date: "1994-07-06", director: "Роберт Земекіс",
    description: "Presidencies, wars and other historical events unfold from the perspective of an Alabama man." },
  { title: "Вартові Галактики", genre: "Action", rating: 8.0, runtime: 121,
    release_date: "2014-08-01", director: "Джеймс Ганн",
    description: "Група супергероїв об'єднується щоб врятувати Галактику." },
  { title: "Паразити", genre: "Thriller", rating: 8.5, runtime: 132,
    release_date: "2019-11-08", director: "Пон Джун-хо",
    description: "Жадібна родина поступово проникає в домогосподарство заможної сім'ї." },
  { title: "Дюна", genre: "Sci-Fi", rating: 8.0, runtime: 155,
    release_date: "2021-10-22", director: "Дені Вільньов",
    description: "Пол Атрейдес рухається до планети Арракіс, щоб забезпечити майбутнє своєї сім'ї." }
]

movies.each { |m| Movie.create!(m) }
puts "Готово! Створено #{Movie.count} фільмів"
