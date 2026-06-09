class RatingsController < ApplicationController
  before_action :require_login

  def create
    movie = Movie.find(params[:movie_id])
    rating = current_user.ratings.find_or_initialize_by(movie: movie)
    rating.score = rating_params[:score]

    if rating.save
      redirect_back fallback_location: movie_path(movie), notice: "Вашу оцінку збережено"
    else
      redirect_back fallback_location: movie_path(movie), alert: "Оберіть оцінку від 1 до 10"
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score)
  end
end
