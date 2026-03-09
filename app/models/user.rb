class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :user_platforms
  has_many :movies, through: :historics
  has_many :historics
  has_many :user_reviews
  has_many :reviews, through: :user_reviews
  has_many :platforms, through: :user_platforms
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

end
