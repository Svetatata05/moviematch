class RandomizerController < ApplicationController
  def index
    @movies = Movie.public_catalog
                   .where.not(tmdb_poster_path: [nil, ""])
                   .order(Arel.sql("RANDOM()"))
                   .limit(18)
    @movies = Movie.public_catalog.order(Arel.sql("RANDOM()")).limit(18) if @movies.empty?
    @target_movie = @movies.to_a.sample || Movie.public_catalog.order(Arel.sql("RANDOM()")).first
  end
end
