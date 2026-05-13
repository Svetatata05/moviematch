class RecommendationService
    def initialize
    end
  
    def popular_movies
      Movie.order(rating: :desc).limit(10)
    end
  end