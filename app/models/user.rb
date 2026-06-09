class User < ApplicationRecord
  before_validation :ensure_share_token

  has_secure_password
  has_many :watchlists, dependent: :destroy
  has_many :movies, through: :watchlists
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :movie_reactions, dependent: :destroy
  has_many :custom_movies, class_name: "Movie", dependent: :destroy

  validates :name, presence: true
  validates :share_token, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  def admin?
    admin
  end

  private

  def ensure_share_token
    self.share_token ||= SecureRandom.urlsafe_base64(12)
  end
end
