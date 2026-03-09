class AddPlatformsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :Netflix, :boolean
    add_column :users, :DisneyPlus, :boolean
    add_column :users, :AmazonPrime, :boolean
    add_column :users, :CanalPlus, :boolean
    add_column :users, :HBO, :boolean
  end
end
