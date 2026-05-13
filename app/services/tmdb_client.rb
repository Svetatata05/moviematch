# Низькорівневий HTTP-клієнт (без змін)
class TmdbClient
    include HTTParty
    base_uri "https://api.themoviedb.org/3"
  
    def self.popular_movies
      get("/movie/popular",
          query: { api_key: ENV["TMDB_API_KEY"], language: "uk-UA" })
    end
  
    def self.search_movies(query)
      get("/search/movie",
          query: { api_key: ENV["TMDB_API_KEY"], query: query })
    end
  
    def self.movie_details(tmdb_id)
      get("/movie/#{tmdb_id}",
          query: { api_key: ENV["TMDB_API_KEY"] })
    end
  end
  
  # Нормалізатор — перетворює "сирі" дані TMDB у хеш ActiveRecord-стилю
  class TmdbNormalizer
    def self.movie(raw)
      {
        title:        raw["title"],
        description:  raw["overview"],
        rating:       raw["vote_average"].to_f.round(1),
        genre:        raw.dig("genres", 0, "name") || "Unknown",
        release_year: raw["release_date"]&.slice(0, 4).to_i,
        poster_url:   "https://image.tmdb.org/t/p/w500#{raw['poster_path']}"
      }
    end
  end
  
  # ФАСАД — єдина точка входу для всієї роботи з фільмами
  class MovieFacade
    CACHE_TTL = 1.hour
  
    def popular_movies(limit: 10)
      Rails.cache.fetch("tmdb_popular", expires_in: CACHE_TTL) do
        response = TmdbClient.popular_movies
        return [] unless response.success?
  
        response["results"]
          .first(limit)
          .map { |raw| TmdbNormalizer.movie(raw) }
      end
    rescue StandardError => e
      Rails.logger.error("TMDB Facade error: #{e.message}")
      Movie.order(rating: :desc).limit(limit) # fallback до локальної БД
    end
  
    def search(query)
      return [] if query.blank?
  
      response = TmdbClient.search_movies(query)
      return Movie.where("title ILIKE ?", "%#{query}%") unless response.success?
  
      response["results"].map { |raw| TmdbNormalizer.movie(raw) }
    end
  
    def find_or_sync(tmdb_id)
      movie = Movie.find_by(tmdb_id: tmdb_id)
      return movie if movie
  
      raw = TmdbClient.movie_details(tmdb_id)
      return nil unless raw.success?
  
      Movie.create!(TmdbNormalizer.movie(raw).merge(tmdb_id: tmdb_id))
    end
  end
  
  # Контролер — чистий, без знань про TMDB
  class MoviesController < ApplicationController
    def initialize
      @facade = MovieFacade.new
      super
    end
  
    def index
      @movies = @facade.popular_movies
    end
  
    def search
      @movies = @facade.search(params[:query])
    end
  
    def popular
      @movies = @facade.popular_movies(limit: 10)
    end
  end