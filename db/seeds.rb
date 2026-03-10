# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."
Historic.destroy_all
Review.destroy_all
Movie.destroy_all
Platform.destroy_all
User.destroy_all

puts "Creating platforms..."
netflix = Platform.create!(name: "Netflix")
prime = Platform.create!(name: "Prime Video")
disney = Platform.create!(name: "Disney+")

puts "Creating movies..."
movie1 = Movie.create!(
  title: "Inception",
  synopsis: "Un voleur infiltre les rêves pour voler des secrets.",
  year: 2010,
  duration: 148,
  rating: 8.8,
  category: "Science-fiction",
  platform: netflix,
  director: "Christopher Nolan",
  poster_url: "inception.jpg",
  trailer: "https://www.youtube.com/watch?v=YoHD9XEInc0",
  actors: "Leonardo DiCaprio, Joseph Gordon-Levitt, Elliot Page"
)

movie2 = Movie.create!(
  title: "Interstellar",
  synopsis: "Un groupe d'explorateurs voyage à travers un trou de ver.",
  year: 2014,
  duration: 169,
  rating: 8.6,
  category: "Science-fiction",
  platform: prime,
  director: "Christopher Nolan",
  poster_url: "interstellar.jpg",
  trailer: "https://www.youtube.com/watch?v=zSWdZVtXT7E",
  actors: "Matthew McConaughey, Anne Hathaway, Jessica Chastain"
)

puts "Creating user..."
user = User.create!(email: "test@example.com", password: "password")

puts "Creating reviews..."
Review.create!(movie: movie1, rating: 9, comment: "Chef d'œuvre visuel.")
Review.create!(movie: movie1, rating: 8, comment: "Très intelligent et captivant.")
Review.create!(movie: movie2, rating: 10, comment: "Magnifique et émouvant.")

puts "Creating historic..."
Historic.create!(user: user, movie: movie1)
Historic.create!(user: user, movie: movie2)

puts "Done!"
