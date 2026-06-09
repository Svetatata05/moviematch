require 'net/http'
require 'json'

namespace :tmdb do
  def youtube_trailer_from(detail)
    detail.dig('videos', 'results')&.find do |video|
      video['site'] == 'YouTube' && video['type'].in?(%w[Trailer Teaser])
    end
  end

  def fetch_tmdb_json(path, api_key, language: "uk-UA", append: nil)
    query = "api_key=#{api_key}&language=#{language}"
    query += "&append_to_response=#{append}" if append.present?
    JSON.parse(Net::HTTP.get(URI("https://api.themoviedb.org/3/#{path}?#{query}")))
  end

  desc "Import movies and TV series from TMDB"
  task import_movies: :environment do
    api_key = 'b2fd1a1306677a867d05bcb05f98b7af'
    imported = 0

    puts "Починаємо імпорт фільмів і серіалів з TMDB..."

    sources = [
      { media_type: "movie", endpoint: "movie/popular", pages: 8 },
      { media_type: "tv", endpoint: "tv/popular", pages: 3 }
    ]

    sources.each do |source|
      (1..source[:pages]).each do |page|
        url = "https://api.themoviedb.org/3/#{source[:endpoint]}?api_key=#{api_key}&language=uk-UA&page=#{page}"
        data = JSON.parse(Net::HTTP.get(URI(url)))

        data.fetch('results', []).each do |item|
          next if item['poster_path'].nil?

          type = source[:media_type]
          detail = fetch_tmdb_json("#{type}/#{item['id']}", api_key, append: "credits,videos,release_dates,content_ratings")

          genres = detail['genres']&.map { |genre| genre['name'] }&.compact
          trailer = youtube_trailer_from(detail)
          if trailer.blank?
            english_detail = fetch_tmdb_json("#{type}/#{item['id']}", api_key, language: "en-US", append: "videos")
            trailer = youtube_trailer_from(english_detail)
          end
          creator = if type == "tv"
            detail['created_by']&.map { |person| person['name'] }&.join(', ')
          else
            detail.dig('credits', 'crew')&.find { |person| person['job'] == 'Director' }&.dig('name')
          end
          content_rating = if type == "movie"
            detail.dig('release_dates', 'results')&.find { |country| country['iso_3166_1'] == 'US' }&.dig('release_dates')&.first&.dig('certification')
          else
            detail.dig('content_ratings', 'results')&.find { |country| country['iso_3166_1'] == 'US' }&.dig('rating')
          end

          movie = Movie.find_or_initialize_by(tmdb_id: item['id'], media_type: type)
          movie.assign_attributes(
            title: detail['title'] || detail['name'],
            original_title: detail['original_title'] || detail['original_name'],
            original_language: detail['original_language'],
            description: detail['overview'],
            rating: detail['vote_average'].to_f.round(1),
            tmdb_poster_path: detail['poster_path'],
            tmdb_backdrop_path: detail['backdrop_path'],
            trailer_key: trailer&.dig('key'),
            genre: genres&.join(', '),
            runtime: type == "tv" ? detail['episode_run_time']&.first : detail['runtime'],
            release_date: (detail['release_date'] || detail['first_air_date']).presence,
            director: creator,
            tagline: detail['tagline'],
            status: detail['status'],
            budget: type == "movie" ? detail['budget'] : nil,
            revenue: type == "movie" ? detail['revenue'] : nil,
            content_rating: content_rating.presence
          )

          if movie.save
            imported += 1
            puts "✓ #{movie.media_label}: #{movie.title}"
          end
        end

        sleep 0.3
      end
    end

    puts "\nГотово! Імпортовано/оновлено #{imported} записів."
  end

  desc "Refresh missing trailer keys from TMDB with English fallback"
  task refresh_missing_trailers: :environment do
    api_key = 'b2fd1a1306677a867d05bcb05f98b7af'
    updated = 0

    Movie.where(trailer_key: [nil, ""]).where.not(tmdb_id: nil).find_each do |movie|
      detail = fetch_tmdb_json("#{movie.media_type}/#{movie.tmdb_id}", api_key, append: "videos")
      trailer = youtube_trailer_from(detail)

      if trailer.blank?
        english_detail = fetch_tmdb_json("#{movie.media_type}/#{movie.tmdb_id}", api_key, language: "en-US", append: "videos")
        trailer = youtube_trailer_from(english_detail)
      end

      next if trailer.blank?

      movie.update!(trailer_key: trailer['key'])
      updated += 1
      puts "✓ #{movie.title}"
      sleep 0.15
    end

    puts "\nОновлено трейлерів: #{updated}"
  end
end
