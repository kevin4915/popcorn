# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Nettoyage de la base de données..."
Movie.destroy_all

puts "Création de 5 films avec leurs acteurs..."

movies = [
  {
    title: "Inception",
    year: 2010,
    category: "Science-Fiction",
    synopsis: "Un voleur qui dérobe des secrets dans les rêves.",
    poster_url: "https://image.tmdb.org/t/p/w500/8IB2e4R45WjN61rRUiNyN70F11T.jpg",
    actors: "Leonardo DiCaprio, Joseph Gordon-Levitt, Elliot Page"
  },
  {
    title: "The Dark Knight",
    year: 2008,
    category: "Action",
    synopsis: "Batman affronte le Joker pour sauver Gotham.",
    poster_url: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haZ1Z5t5.jpg",
    actors: "Christian Bale, Heath Ledger, Aaron Eckhart"
  },
  {
    title: "Interstellar",
    year: 2014,
    category: "Science-Fiction",
    synopsis: "Une équipe d'astronautes voyage à travers un trou de ver.",
    poster_url: "https://image.tmdb.org/t/p/w500/gEU2QpI6Eki7ygjUo41N50yN2D9.jpg",
    actors: "Matthew McConaughey, Anne Hathaway, Jessica Chastain"
  },
  {
    title: "Pulp Fiction",
    year: 1994,
    category: "Crime",
    synopsis: "Plusieurs histoires de criminels s'entremêlent à Los Angeles.",
    poster_url: "https://image.tmdb.org/t/p/w500/d5iSGBOaN195qQW3B0r8MhH39Uo.jpg",
    actors: "John Travolta, Uma Thurman, Samuel L. Jackson"
  },
  {
    title: "Parasite",
    year: 2019,
    category: "Drame",
    synopsis: "Une famille pauvre s'infiltre dans une famille riche.",
    poster_url: "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbL3vT1.jpg",
    actors: "Song Kang-ho, Lee Sun-kyun, Cho Yeo-jeong"
  }
]

movies.each do |movie_data|
  Movie.create!(movie_data)
end

puts "Base de données prête avec #{Movie.count} films !"
