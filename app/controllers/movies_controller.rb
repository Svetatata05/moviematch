class MoviesController < ApplicationController
    def index
      Rails.logger.info "=== Отримано запит на список фільмів ==="
      @movies = Movie.all
      Rails.logger.info "Завантажено #{@movies.count} фільмів"
      render json: @movies
    end
  
    def show
      @movie = Movie.find(params[:id])
      Rails.logger.info "Перегляд фільму: #{@movie.title} (ID: #{@movie.id})"
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Фільм не знайдено: ID #{params[:id]}"
      Sentry.capture_exception(e)
      render json: { error: "Movie not found" }, status: :not_found
    end
  
    def search
      Rails.logger.info "Пошук фільмів за запитом: #{params[:query]}"
      @movies = MovieSearchService.call(search_params)
      Rails.logger.info "Знайдено #{@movies.count} фільмів"
      render json: @movies
    end
  
    def popular
      Rails.logger.info "Запит популярних фільмів"
      @movies = ServiceLocator.recommendation_service.popular_movies
      render json: @movies
    end
  
    private
  
    def search_params
      params.permit(:query, :genre, :year, :min_rating, :sort_by, :page)
    end
  end