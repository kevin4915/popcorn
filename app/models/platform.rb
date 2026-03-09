class Platform < ApplicationRecord
  has_many :user_platforms, dependent: :destroy
  has_many :users, through: :user_platforms
end
