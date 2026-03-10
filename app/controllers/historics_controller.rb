class HistoricsController < ApplicationController
  def index
    @movies = Movie.all
  end
end
