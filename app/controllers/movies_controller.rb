class MoviesController < ApplicationController
  def index
    @movies = Movie.all
  end

  def swipe
    @movie = Movie.find(params[:id])
    if params[:decision] == "like"
      Historic.create!(user: current_user, movie: @movie)
    end
    head :ok
  end
end
