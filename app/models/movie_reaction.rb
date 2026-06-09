class MovieReaction < ApplicationRecord
  STATUSES = {
    want_to_watch: "want_to_watch",
    disliked: "disliked",
    seen: "seen"
  }.freeze

  belongs_to :user
  belongs_to :movie

  validates :status, inclusion: { in: STATUSES.values }
  validates :user_id, uniqueness: { scope: :movie_id }
end
