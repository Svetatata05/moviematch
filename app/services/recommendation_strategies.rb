# Спільний інтерфейс для всіх стратегій
module RecommendationStrategies
    class Base
      def call(user: nil, limit: 10)
        raise NotImplementedError, "#{self.class} must implement #call"
      end
    end
  
    # Стратегія 1 — популярні фільми (за рейтингом)
    class Popular < Base
      def call(user: nil, limit: 10)
        Movie.order(rating: :desc).limit(limit)
      end
    end
  
    # Стратегія 2 — персоналізовані (на основі watchlist)
    class Personalized < Base
      def call(user: nil, limit: 10)
        return Popular.new.call(limit: limit) unless user
  
        watched_genres = user.movies.pluck(:genre).uniq
        Movie.where(genre: watched_genres)
             .where.not(id: user.movie_ids)
             .order(rating: :desc)
             .limit(limit)
      end
    end
  
    # Стратегія 3 — за жанром
    class ByGenre < Base
      def initialize(genre)
        @genre = genre
      end
  
      def call(user: nil, limit: 10)
        Movie.where(genre: @genre).order(rating: :desc).limit(limit)
      end
    end
  end
  
  # Контекст, який делегує виконання стратегії
  class RecommendationService
    def initialize(strategy: RecommendationStrategies::Popular.new)
      @strategy = strategy
    end
  
    def recommend(user: nil, limit: 10)
      @strategy.call(user: user, limit: limit)
    end
  end
  
  # Контролер стає чистим — не знає про конкретні алгоритми
  class MoviesController < ApplicationController
    def popular
      strategy = current_user ?
        RecommendationStrategies::Personalized.new :
        RecommendationStrategies::Popular.new
  
      service = RecommendationService.new(strategy: strategy)
      @movies = service.recommend(user: current_user)
    end
  end