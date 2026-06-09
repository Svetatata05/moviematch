class MovieReactionsController < ApplicationController
  before_action :require_login

  def destroy
    reaction = current_user.movie_reactions.find(params[:id])
    movie = reaction.movie
    current_user.watchlists.where(movie: movie).destroy_all
    reaction.destroy
    destroy_orphan_manual_movie(movie)
    redirect_back fallback_location: user_path(current_user), notice: "Фільм видалено з папки"
  end
end
