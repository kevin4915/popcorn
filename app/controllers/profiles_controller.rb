class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @pending_requests = current_user.received_friendships.where(status: 'pending') if @user == current_user
    @recent_movies = Movie.joins(:historics)
      .where(historics: { user_id: @user.id })
      .order("historics.created_at DESC")
      .limit(12)
  end
end
