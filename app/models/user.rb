class User < ApplicationRecord
    has_secure_password
  
    has_many :watchlists
    has_many :movies, through: :watchlists
  
    validates :email, presence: true, uniqueness: true
  end