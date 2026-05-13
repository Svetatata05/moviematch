
  class MovieSearchService
    def self.call(params = {})
      MovieQueryBuilder.new
        .with_title(params[:query])
        .with_genre(params[:genre])
        .with_year(params[:year])
        .with_min_rating(params[:min_rating])
        .sorted_by(params[:sort_by] || "rating")
        .paginated(page: params[:page] || 1)
        .results
    end
  end