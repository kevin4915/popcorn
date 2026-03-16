class CommunitiesController < ApplicationController
  def index
    @filter = params[:filter] || 'all'

    if @filter == 'friends'
      friend_ids = current_user.friends.pluck(:id)
      @recent_likes = Historic.includes(:user, :movie)
                              .where(user_id: friend_ids)
                              .order(created_at: :desc)
                              .page(params[:page]).per(20)
    else
      @recent_likes = Historic.includes(:user, :movie)
                              .order(created_at: :desc)
                              .page(params[:page]).per(20)
    end
  end
end
