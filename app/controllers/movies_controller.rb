class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def show
    @movie = Movie.find(params[:id])
  end

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
