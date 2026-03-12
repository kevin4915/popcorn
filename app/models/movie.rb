class Movie < ApplicationRecord
  has_many :reviews
  has_many :historics, dependent: :destroy
  has_many :users, through: :historics

  def actor_names
    return "" if actors.blank?

    JSON.parse(actors).map { |actor| actor["name"] }.join(", ")
  rescue JSON::ParserError, NoMethodError
    actors
  end
end
