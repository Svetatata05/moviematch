class MovieQueryBuilder
    def initialize
      @scope = Movie.all
    end
  
    def with_title(query)
      return self if query.blank?
      @scope = @scope.where("title ILIKE ?", "%#{query}%")
      self
    end
  
    def with_genre(genre)
      return self if genre.blank?
      @scope = @scope.where(genre: genre)
      self
    end
  
    def with_year(year)
      return self if year.blank?
      @scope = @scope.where(release_year: year.to_i)
      self
    end
  
    def with_min_rating(rating)
      return self if rating.blank?
      @scope = @scope.where("rating >= ?", rating.to_f)
      self
    end
  
    def sorted_by(field, direction = :desc)
      allowed = %w[rating release_year title]
      return self unless allowed.include?(field.to_s)
      @scope = @scope.order(field => direction)
      self
    end
  
    def paginated(page: 1, per_page: 20)
      @scope = @scope.offset((page.to_i - 1) * per_page).limit(per_page)
      self
    end
  
    def build
      @scope
    end
  
    alias_method :results, :build
  end