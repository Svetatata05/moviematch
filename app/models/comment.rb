class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :movie

  validates :body, presence: true, length: { maximum: 1_000 }
end
