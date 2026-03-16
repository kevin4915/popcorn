class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 30 }
  validates :first_name, presence: true
  validates :last_name, presence: true

  has_many :historics
  has_many :movies, through: :historics
  has_many :user_platforms
  has_many :user_reviews
  has_many :reviews, through: :user_reviews
  has_many :platforms, through: :user_platforms
  has_many :user_badges
  has_many :badges, through: :user_badges
  has_many :comments

  has_one_attached :avatar

  has_many :sent_friendships, class_name: 'Friendship', foreign_key: 'user_id', dependent: :destroy
  has_many :sent_friend_requests, through: :sent_friendships, source: :friend

  has_many :received_friendships, class_name: 'Friendship', foreign_key: 'friend_id', dependent: :destroy
  has_many :received_friend_requests, through: :received_friendships, source: :user

  def friends
    friend_ids = sent_friendships.where(status: 'accepted').pluck(:friend_id) +
                 received_friendships.where(status: 'accepted').pluck(:user_id)
    User.where(id: friend_ids)
  end

  def pending_friend_requests
    received_friendships.where(status: 'pending')
  end

  def friend_with?(user)
    friends.include?(user)
  end

  def pending_request_sent_to?(user)
    sent_friendships.exists?(friend: user, status: 'pending')
  end

  def pending_request_received_from?(user)
    received_friendships.exists?(user: user, status: 'pending')
  end

  def friendship_with(user)
    sent_friendships.find_by(friend: user) ||
      received_friendships.find_by(user: user)
  end

  def check_for_badges
    count = historics.count
    badges << Badge.find_by(name: "Découvreur") if count >= 10 && !badges.exists?(name: "Découvreur")
    badges << Badge.find_by(name: "Grand Cinéphile") if count >= 50 && !badges.exists?(name: "Grand Cinéphile")
  end

  def liked_movies_count
    historics.count
  end

  def recent_liked_movies
    historics.includes(:movie).order(created_at: :desc).limit(10).map(&:movie)
  end

  def display_name
    username.present? ? "@#{username}" : first_name
  end
end
