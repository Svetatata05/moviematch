class CommentsController < ApplicationController
  before_action :require_login

  def create
    movie = Movie.find(params[:movie_id])
    comment = movie.comments.build(comment_params.merge(user: current_user))

    if comment.save
      redirect_to movie_path(movie), notice: "Коментар додано"
    else
      redirect_to movie_path(movie), alert: "Коментар не може бути порожнім"
    end
  end

  def destroy
    comment = current_user.comments.find(params[:id])
    movie = comment.movie
    comment.destroy
    redirect_to movie_path(movie), notice: "Коментар видалено"
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
