module Admin
  class MoviesController < ApplicationController
    before_action :require_admin

    def new
      @movie = Movie.new(media_type: "movie", rating: 0)
    end

    def create
      @movie = Movie.new(movie_params)
      @movie.manually_added = false
      @movie.user = nil
      @movie.rating = 0 if @movie.rating.blank?
      @movie.release_date = Date.new(@movie.release_year, 1, 1) if @movie.release_year.present?
      uploaded_poster = save_uploaded_poster(params.dig(:movie, :poster_file))
      @movie.poster_url = uploaded_poster if uploaded_poster.present?

      if @movie.save
        redirect_to admin_root_path, notice: "#{@movie.title} додано до загального каталогу"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      movie = Movie.find(params[:id])
      movie.destroy
      redirect_to admin_root_path, notice: "Фільм видалено"
    end

    private

    def movie_params
      params.require(:movie).permit(:title, :original_title, :media_type, :genre, :release_year, :runtime, :description, :poster_url, :rating)
    end
  end
end
