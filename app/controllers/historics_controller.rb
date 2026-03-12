class HistoricsController < ApplicationController
  def index
    @movies = current_user.movies
  end

  def destroy
    @historic = current_user.historics.find(params[:id])
    @historic.destroy
    redirect_to historics_path, notice: "Film retiré de ta liste !"
  end
end
