module ApplicationHelper
  UI_TEXT = {
    catalog: ["Каталог", "Catalog"],
    random: ["Рандом", "Random"],
    swipes: ["Підбір фільмів", "Movie match"],
    sign_in: ["Увійти", "Sign in"],
    sign_up: ["Реєстрація", "Sign up"],
    profile: ["Профіль", "Profile"],
    log_out: ["Вийти", "Log out"],
    catalog_heading: ["Знайдіть фільм під свій настрій.", "Find a movie for your mood."],
    catalog_subtitle: ["Каталог із рейтингами, жанрами та швидким пошуком для персональних рекомендацій.", "A catalog with ratings, genres and fast search for personal recommendations."],
    search: ["Шукати", "Search"],
    search_placeholder: ["Назва, жанр, опис або режисер...", "Title, genre, description or director..."],
    popular_searches: ["Популярні запити:", "Popular searches:"],
    where_watch: ["Де подивитися", "Where to watch"],
    all_items: ["Усі записи", "All titles"],
    has_trailer: ["Є трейлер", "Has trailer"],
    has_tmdb: ["Є сторінка TMDB", "Has TMDB page"],
    add_custom_movie: ["Додати свій фільм", "Add your movie"],
    share: ["Поділитися", "Share"]
  }.freeze

  def mm_t(key)
    pair = UI_TEXT.fetch(key)
    english? ? pair.last : pair.first
  end

  def public_url_for(path)
    "#{public_base_url}#{path}"
  end

  private

  def public_base_url
    return request.base_url unless Rails.env.development?

    host = request.host
    if host == "localhost" || host.start_with?("127.")
      "http://#{local_network_ip}:#{request.port}"
    else
      request.base_url
    end
  end

  def local_network_ip
    Socket.ip_address_list.find do |addr|
      addr.ipv4? && !addr.ipv4_loopback? && addr.ip_address.start_with?("192.168.", "10.", "172.")
    end&.ip_address || request.host
  end
end
