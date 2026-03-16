class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @pending_requests = current_user.received_friendships.where(status: 'pending') if @user == current_user
  end
end
