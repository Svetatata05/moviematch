class MoviesController < ApplicationController
    def index
      @movies = Movie.all
    end
  
    def show
      @movie = Movie.find(params[:id])
    end
  
    def search
      @movies = Movie.where("title LIKE ?", "%#{params[:query]}%")
    end
  
    def popular
      @movies = ServiceLocator.recommendation_service.popular_movies
    end
    def search
        @movies = MovieSearchService.call(search_params)
      end
      private

      def search_params
        params.permit(:query, :genre, :year, :min_rating, :sort_by, :page)
      end
    end
  end