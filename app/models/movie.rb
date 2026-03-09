class Movie < ApplicationRecord
  has_many :reviews
  has_many :historics
  has_many :users, through: :historics
end
