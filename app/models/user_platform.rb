class UserPlatform < ApplicationRecord
  belongs_to :user, foreign_key: 'user_id'
  belongs_to :platform, foreign_key: 'platform_id'
end
