class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self

  private

  def not_self
    errors.add(:friend_id, "ne peut pas être vous-même") if user_id == friend_id
  end
end
