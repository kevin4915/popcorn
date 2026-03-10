class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def show
    @movie = Movie.find(params[:id])
  end

  def index
    @movies = Movie.all
    render :swipe
  end

  def swipe
    @movie = Movie.find(params[:id])
    Historic.create!(user: current_user, movie: @movie) if params[:decision] == "like"
    head :ok
  end
end
