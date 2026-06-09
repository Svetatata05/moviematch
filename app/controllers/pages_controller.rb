class PagesController < ApplicationController
    def welcome
      @popular_movies = Movie.public_catalog.where.not(tmdb_poster_path: nil)
                             .order(rating: :desc)
                             .limit(10)
      @new_movies = Movie.public_catalog
                         .where.not(release_date: nil)
                         .order(release_date: :desc)
                         .limit(10)
      top_genres = Movie.public_catalog
                        .where.not(genre: [nil, ""])
                        .pluck(:genre)
                        .flat_map { |genre| genre.to_s.split(",").map(&:strip) }
                        .reject(&:blank?)
                        .tally
                        .sort_by { |_, count| -count }
                        .first(3)
                        .map(&:first)
      @genre_sections = top_genres.map do |genre|
        movies = Movie.public_catalog.where("genre ILIKE ?", "%#{genre}%").order(rating: :desc).limit(10)
        [genre, movies]
      end
    end
  end
