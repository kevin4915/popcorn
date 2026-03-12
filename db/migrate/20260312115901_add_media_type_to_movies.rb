class AddMediaTypeToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :media_type, :string
  end
end
