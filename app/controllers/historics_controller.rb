class HistoricsController < ApplicationController
  def films
    @movies = current_user.movies.where(media_type: "movie")
  end

  def series
    @movies = current_user.movies.where(media_type: "tv")
  end

  def destroy
    @historic = current_user.historics.find(params[:id])
    @historic.destroy
    redirect_back fallback_location: films_historics_path, notice: "Retiré de ta liste !"
  end
end
