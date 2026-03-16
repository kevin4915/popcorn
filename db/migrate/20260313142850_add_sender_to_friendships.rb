class AddSenderToFriendships < ActiveRecord::Migration[8.1]
  def change
    add_column :friendships, :sender_id, :integer
  end
end
