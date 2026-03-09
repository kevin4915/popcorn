class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.decimal :rating
      t.text :comment
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
  end
end
