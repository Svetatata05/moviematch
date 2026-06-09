class SwipesController < ApplicationController
  before_action :require_login

  def index
    reacted_ids = current_user.movie_reactions.select(:movie_id)
    watchlist_ids = current_user.watchlists.select(:movie_id)

    @movies = Movie.public_catalog
                   .where.not(id: reacted_ids)
                   .where.not(id: watchlist_ids)
                   .order(rating: :desc, created_at: :desc)
                   .limit(24)
  end

  def create
    movie = Movie.find(params[:movie_id])
    status = reaction_params[:status]

    unless MovieReaction::STATUSES.value?(status)
      redirect_to swipes_path, alert: "Невідома дія"
      return
    end

    reaction = current_user.movie_reactions.find_or_initialize_by(movie: movie)
    reaction.status = status
    reaction.save!

    if status == MovieReaction::STATUSES[:want_to_watch]
      current_user.watchlists.find_or_create_by!(movie: movie)
    else
      current_user.watchlists.where(movie: movie).destroy_all
    end

    respond_to do |format|
      format.html { redirect_back fallback_location: user_path(current_user), notice: reaction_notice(status, movie) }
      format.json { render json: { ok: true, status: status, message: reaction_notice(status, movie) } }
    end
  end

  private

  def reaction_params
    params.require(:movie_reaction).permit(:status)
  end

  def reaction_notice(status, movie)
    case status
    when MovieReaction::STATUSES[:want_to_watch]
      "#{movie.title} додано в “Хочу подивитись”"
    when MovieReaction::STATUSES[:seen]
      "#{movie.title} додано в “Бачив/ла”"
    else
      "#{movie.title} додано в “Не подобається”"
    end
  end
end
