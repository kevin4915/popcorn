class CreateBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges do |t|
      t.string :name
      t.string :description
      t.string :icon

      t.timestamps
    end
  end
end
