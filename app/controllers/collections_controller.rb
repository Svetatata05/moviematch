class CollectionsController < ApplicationController
  def show
    @user = User.find_by!(share_token: params[:token])
    @watchlist = @user.watchlists.includes(:movie).order(created_at: :desc)
    @ratings_by_movie = @user.ratings.where(movie_id: @watchlist.map(&:movie_id)).index_by(&:movie_id)
  rescue ActiveRecord::RecordNotFound
    redirect_to movies_path, alert: "Публічну підбірку не знайдено"
  end
end
