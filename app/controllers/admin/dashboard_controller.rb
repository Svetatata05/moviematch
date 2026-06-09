module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
      @users = User.order(created_at: :desc)
      @recent_reactions = MovieReaction.includes(:user, :movie).order(updated_at: :desc).limit(20)
      @custom_movies = Movie.where(manually_added: true).includes(:user).order(created_at: :desc)
      @recent_ratings = Rating.includes(:user, :movie).order(updated_at: :desc).limit(20)
      @recent_comments = Comment.includes(:user, :movie).order(created_at: :desc).limit(20)
      @catalog_movies = Movie.public_catalog.order(created_at: :desc)
    end
  end
end
