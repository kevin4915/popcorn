class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @recent_movies = Movie.joins(:historics)
      .where(historics: { user_id: @user.id })
      .order("historics.created_at DESC")
      .limit(12)
  end
end
