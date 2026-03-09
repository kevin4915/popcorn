class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :synopsis
      t.integer :year
      t.integer :duration
      t.decimal :rating
      t.string :category
      t.string :platform
      t.string :director
      t.string :poster_url
      t.string :trailer

      t.timestamps
    end
  end
end
