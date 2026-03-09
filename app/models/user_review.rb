class UserReview < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'
  belongs_to :review, foreign_key: 'review_id'
end
