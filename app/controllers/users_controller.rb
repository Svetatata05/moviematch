class UsersController < ApplicationController
  before_action :require_login, only: [:show]

  def new
    if logged_in?
      redirect_to movies_path, alert: "Ви вже зареєстровані. Спочатку вийдіть з акаунту."
      return
    end
    @user = User.new
  end

  def create
    if logged_in?
      redirect_to movies_path
      return
    end
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to movies_path, notice: "Акаунт створено успішно!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
    @watchlist_items = @user.watchlists.includes(:movie).order(created_at: :desc)
    @watchlist = @watchlist_items
    @watchlist_count = @watchlist_items.count
    @reactions = @user.movie_reactions.includes(:movie).order(updated_at: :desc)
    saved_movies = @watchlist_items.map(&:movie)
    saved_movie_ids = saved_movies.map(&:id)
    @ratings_by_movie = @user.ratings.where(movie_id: saved_movie_ids).index_by(&:movie_id)
    @total_runtime = saved_movies.sum { |movie| movie.runtime.to_i }
    user_scores = @ratings_by_movie.values.map(&:score)
    @average_user_rating = user_scores.any? ? (user_scores.sum.to_f / user_scores.size).round(1) : nil
    @rated_count = user_scores.size
    @favorite_genres = saved_movies
      .filter_map(&:genre)
      .tally
      .sort_by { |_, count| -count }
      .first(4)
      recommendation_scope = Movie.public_catalog.where.not(id: saved_movie_ids)
    recommendation_scope = recommendation_scope.where(genre: @favorite_genres.map(&:first)) if @favorite_genres.any?
    @recommendations = recommendation_scope.order(rating: :desc).limit(6)

    @want_movies = (saved_movies + @reactions.select { |reaction| reaction.status == MovieReaction::STATUSES[:want_to_watch] }.map(&:movie)).uniq
    @disliked_movies = @reactions.select { |reaction| reaction.status == MovieReaction::STATUSES[:disliked] }.map(&:movie)
    @seen_movies = @reactions.select { |reaction| reaction.status == MovieReaction::STATUSES[:seen] }.map(&:movie)
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
