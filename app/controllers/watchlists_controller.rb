class WatchlistsController < ApplicationController
    before_action :require_login
  
    def index
      redirect_to user_path(current_user)
      return

      @watchlist = current_user.watchlists.includes(:movie).order(created_at: :desc)
      saved_movies = @watchlist.map(&:movie)
      saved_movie_ids = saved_movies.map(&:id)
      @ratings_by_movie = current_user.ratings.where(movie_id: saved_movie_ids).index_by(&:movie_id)
      @total_runtime = saved_movies.sum { |movie| movie.runtime.to_i }
      user_scores = @ratings_by_movie.values.map(&:score)
      @average_user_rating = user_scores.any? ? (user_scores.sum.to_f / user_scores.size).round(1) : nil
      @rated_count = user_scores.size
      @favorite_genres = saved_movies
        .filter_map(&:genre)
        .tally
        .sort_by { |_, count| -count }
        .first(4)

      recommendation_scope = Movie.where.not(id: saved_movie_ids)
      if @favorite_genres.any?
        recommendation_scope = recommendation_scope.where(genre: @favorite_genres.map(&:first))
      end
      @recommendations = recommendation_scope.order(rating: :desc).limit(6)
    end
  
    def create
      movie = Movie.find(params[:movie_id])
      unless current_user.watchlists.exists?(movie: movie)
        current_user.watchlists.create!(movie: movie)
        flash[:notice] = "#{movie.title} додано до списку"
      end
      redirect_back fallback_location: movies_path
    end
  
    def destroy
      watchlist = current_user.watchlists.find(params[:id])
      movie = watchlist.movie
      current_user.movie_reactions.where(movie: movie, status: MovieReaction::STATUSES[:want_to_watch]).destroy_all
      watchlist.destroy
      destroy_orphan_manual_movie(movie)
      flash[:notice] = "Фільм видалено зі списку"
      redirect_back fallback_location: user_path(current_user)
    end
  end
