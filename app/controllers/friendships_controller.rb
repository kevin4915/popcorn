class FriendshipsController < ApplicationController
  def create
    @friend = User.find(params[:friend_id])
    @friendship = Friendship.new(user: current_user, friend: @friend, status: 'pending')
    if @friendship.save
      redirect_to profile_path(@friend), notice: "Demande envoyée !"
    else
      redirect_to profile_path(@friend), alert: "Impossible d'envoyer la demande."
    end
  end
end
