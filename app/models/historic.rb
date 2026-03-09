class Historic < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'
  belongs_to :movie, foreign_key: 'movie_id'
end
