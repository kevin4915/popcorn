class Badge < ApplicationRecord
  has_many :user_badges
  has_many :users, through: :user_badges

  validates :name, presence: true, uniqueness: true

  def self.seed_default_badges
    create_with(description: "A liké 5 films", icon: "🍿").find_or_create_by(name: "Découvreur")
    create_with(description: "A liké 10 films", icon: "🏆").find_or_create_by(name: "Grand Cinéphile")
    create_with(description: "A liké 15 films", icon: "👑").find_or_create_by(name: "Oscar Popcorn")
  end
end
