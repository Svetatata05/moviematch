class MoviesController < ApplicationController
  before_action :require_login, only: [:new, :create]

  def index
    @movies = Movie.public_catalog
    @movies = @movies.where(provider_filter_clause) if provider_filter_selected?
    @movies = @movies.where(media_type: params[:media_type]) if params[:media_type].present?
    @selected_genres = selected_genres
    @movies = filter_by_genres(@movies, @selected_genres) if @selected_genres.any?
    @movies = sort_movies(@movies)
    @genres = available_genres
    @popular_searches = Movie.public_catalog.order(rating: :desc).limit(3)
  end

  def show
    @movie = Movie.find(params[:id])
    if @movie.manual? && @movie.user != current_user
      redirect_to movies_path, alert: "Фільм не знайдено"
      return
    end
    @similar = Movie.where(genre: @movie.genre)
                    .where(media_type: @movie.media_type)
                    .public_catalog
                    .where.not(id: @movie.id)
                    .order(rating: :desc)
                    .limit(5)
    @in_watchlist = logged_in? && current_user.watchlists.exists?(movie: @movie)
    @comments = @movie.comments.includes(:user).order(created_at: :desc)
    @comment = Comment.new
    @user_rating = logged_in? ? current_user.ratings.find_by(movie: @movie) : nil
    @rating = Rating.new
  rescue ActiveRecord::RecordNotFound
    redirect_to movies_path, alert: "Фільм не знайдено"
  end

  def search
    @query = params[:query].to_s.strip
    if @query.present?
      @movies = search_scope(@query)
    else
      @movies = Movie.public_catalog.order(rating: :desc)
    end
    @selected_genres = selected_genres
    @movies = filter_by_genres(@movies, @selected_genres) if @selected_genres.any?
    @movies = @movies.select { |movie| movie.media_type == params[:media_type] } if @movies.is_a?(Array) && params[:media_type].present?
    @movies = sort_movies(@movies)
    @genres = available_genres
    @popular_searches = Movie.public_catalog.order(rating: :desc).limit(3)
    render :index
  end

  def popular
    @movies = Movie.public_catalog.order(rating: :desc).limit(10)
    @selected_genres = selected_genres
    @genres = available_genres
    @popular_searches = Movie.public_catalog.order(rating: :desc).limit(3)
    render :index
  end

  def new
    @movie = Movie.new(media_type: "movie")
  end

  def create
    @movie = Movie.new(custom_movie_params)
    @movie.rating = 0 if @movie.rating.blank?
    @movie.release_date = Date.new(@movie.release_year, 1, 1) if @movie.release_year.present?
    @movie.user = current_user
    @movie.manually_added = true
    uploaded_poster = save_uploaded_poster(params.dig(:movie, :poster_file))
    @movie.poster_url = uploaded_poster if uploaded_poster.present?

    if @movie.save
      current_user.watchlists.find_or_create_by!(movie: @movie)
      current_user.movie_reactions.find_or_create_by!(movie: @movie) do |reaction|
        reaction.status = MovieReaction::STATUSES[:want_to_watch]
      end
      redirect_to user_path(current_user), notice: "#{@movie.title} додано у ваш список"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def custom_movie_params
    params.require(:movie).permit(:title, :original_title, :media_type, :genre, :release_year, :runtime, :description, :poster_url)
  end

  def search_scope(query)
    fields = %w[title original_title description genre director]
    tokens = query.downcase.split(/\s+/).reject(&:blank?)

    Movie.public_catalog.select do |movie|
      searchable = fields.map { |field| movie.public_send(field).to_s.mb_chars.downcase.to_s }.join(" ")
      tokens.all? { |token| searchable.include?(token.mb_chars.downcase.to_s) }
    end.sort_by { |movie| -(movie.rating || 0) }
  end

  def available_genres
    Movie.public_catalog
         .where.not(genre: [nil, ""])
         .pluck(:genre)
         .flat_map { |genre| split_genres(genre) }
         .uniq
         .sort_by(&:downcase)
  end

  def selected_genres
    Array(params[:genres].presence || params[:genre])
      .flat_map { |genre| split_genres(genre) }
      .uniq
  end

  def split_genres(value)
    value.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def filter_by_genres(scope, genres)
    if scope.is_a?(Array)
      scope.select do |movie|
        movie_genres = split_genres(movie.genre).map { |genre| genre.mb_chars.downcase.to_s }
        genres.all? { |genre| movie_genres.include?(genre.mb_chars.downcase.to_s) }
      end
    else
      genres.reduce(scope) do |relation, genre|
        relation.where(
          "EXISTS (SELECT 1 FROM unnest(string_to_array(COALESCE(movies.genre, ''), ',')) AS g WHERE btrim(g) ILIKE ?)",
          genre
        )
      end
    end
  end

  def sort_movies(scope)
    case params[:sort]
    when "title"
      scope.is_a?(Array) ? scope.sort_by { |movie| movie.title.to_s.mb_chars.downcase.to_s } : scope.order(:title)
    when "newest"
      if scope.is_a?(Array)
        scope.sort_by { |movie| [movie.release_date || Date.new(1, 1, 1), movie.created_at || Time.zone.at(0)] }.reverse
      else
        scope.order(Arel.sql("release_date DESC NULLS LAST, created_at DESC"))
      end
    else
      scope.is_a?(Array) ? scope.sort_by { |movie| -(movie.rating || 0).to_f } : scope.order(rating: :desc)
    end
  end

  def provider_filter_selected?
    params[:provider].present?
  end

  def provider_filter_clause
    case params[:provider]
    when "streaming"
      "tmdb_id IS NOT NULL"
    when "trailer"
      "trailer_key IS NOT NULL AND trailer_key != ''"
    else
      "1=1"
    end
  end
end
