class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  def show
    @movie = Movie.find(params[:id])
  end

  def index
    @movies = Movie.all
  end
end
