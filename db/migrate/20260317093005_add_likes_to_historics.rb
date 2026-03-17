class AddLikesToHistorics < ActiveRecord::Migration[8.1]
  def change
    add_column :historics, :liked, :boolean, default: false
    add_column :historics, :disliked, :boolean, default: false
  end
end
