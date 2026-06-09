class Movie < ApplicationRecord
  has_many :watchlists, dependent: :destroy
  has_many :users, through: :watchlists
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :movie_reactions, dependent: :destroy
  belongs_to :user, optional: true

  validates :title, presence: true
  validates :media_type, inclusion: { in: %w[movie tv] }
  validates :rating, numericality: { greater_than_or_equal_to: 0,
                                     less_than_or_equal_to: 10 }, allow_nil: true

  scope :public_catalog, -> { where(manually_added: false) }

  def manual?
    manually_added?
  end

  def poster_url
    tmdb_poster_path.present? ? "https://image.tmdb.org/t/p/w500#{tmdb_poster_path}" : self[:poster_url].presence
  end

  def backdrop_url
    tmdb_backdrop_path.present? ? "https://image.tmdb.org/t/p/original#{tmdb_backdrop_path}" : nil
  end

  def trailer_embed_url
    trailer_key.present? ? "https://www.youtube.com/embed/#{trailer_key}?autoplay=1" : nil
  end

  def trailer_search_url
    "https://www.youtube.com/results?search_query=#{ERB::Util.url_encode("#{original_title.presence || title} official trailer")}"
  end

  def tmdb_url
    return nil unless tmdb_id.present?

    path = tv? ? "tv" : "movie"
    "https://www.themoviedb.org/#{path}/#{tmdb_id}"
  end

  def justwatch_url
    "https://www.justwatch.com/ua/search?q=#{ERB::Util.url_encode(original_title.presence || title)}"
  end

  def tv?
    media_type == "tv"
  end

  def media_label
    tv? ? "Серіал" : "Фільм"
  end

  def year
    release_date&.year
  end

  def duration_formatted
    return nil unless runtime
    hours = runtime / 60
    mins = runtime % 60
    hours.positive? ? "#{hours}г #{mins}хв" : "#{mins}хв"
  end

  def money_formatted(value)
    return "Невідомо" if value.blank? || value.to_i.zero?

    "$#{ActiveSupport::NumberHelper.number_to_delimited(value.to_i)}"
  end

  def rating_percent
    [[((rating || 0).to_f * 10).round, 0].max, 100].min
  end
end
