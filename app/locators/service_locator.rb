class ServiceLocator
    def self.movie_search_service
      MovieSearchService.new
    end
  
    def self.recommendation_service
      RecommendationService.new
    end
  end