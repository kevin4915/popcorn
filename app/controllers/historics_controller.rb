class HistoricsController < ApplicationController
  def films
    @movies = Movie.joins(:historics)
      .where(historics: { user_id: current_user.id }, media_type: "movie")
      .order("historics.created_at DESC")
      .page(params[:page]).per(10)
  end

  def series
    @movies = Movie.joins(:historics)
      .where(historics: { user_id: current_user.id }, media_type: "tv")
      .order("historics.created_at DESC")
      .page(params[:page]).per(10)
  end

  def destroy
    @historic = current_user.historics.find(params[:id])
    @historic.destroy
    redirect_back fallback_location: films_historics_path, notice: "Retiré de ta liste !"
  end

  def like
    @historic = current_user.historics.find(params[:id])
    @historic.update(liked: !@historic.liked, disliked: false)
    redirect_back fallback_location: films_historics_path
  end

  def dislike
    @historic = current_user.historics.find(params[:id])
    @historic.update(disliked: !@historic.disliked, liked: false)
    redirect_back fallback_location: films_historics_path
  end
end
