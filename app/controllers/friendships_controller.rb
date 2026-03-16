class FriendshipsController < ApplicationController
  before_action :set_friendship, only: %i[accept decline destroy]

  def create
    @friend = User.find(params[:friend_id])
    existing = Friendship.where(user_id: current_user.id, friend_id: @friend.id)
                         .or(Friendship.where(user_id: @friend.id, friend_id: current_user.id))
                         .first
    if existing
      redirect_to profile_path(@friend), alert: "Une demande existe déjà."
      return
    end

    @friendship = Friendship.new(
      user_id: current_user.id,
      friend_id: @friend.id,
      sender_id: current_user.id,
      status: 'pending'
    )

    if @friendship.save
      redirect_to profile_path(@friend), notice: "Demande envoyée à @#{@friend.username} !"
    else
      redirect_to profile_path(@friend), alert: "Impossible d'envoyer la demande."
    end
  end

  def accept
    if @friendship.friend == current_user
      @friendship.update(status: 'accepted')
      redirect_back fallback_location: root_path,
                    notice: "Vous êtes maintenant amis avec @#{@friendship.user.username} !"
    else
      redirect_back fallback_location: root_path, alert: "Action non autorisée."
    end
  end

  def decline
    if @friendship.friend == current_user || @friendship.user == current_user
      @friendship.destroy
      redirect_back fallback_location: root_path, notice: "Demande refusée."
    else
      redirect_back fallback_location: root_path, alert: "Action non autorisée."
    end
  end

  def destroy
    if @friendship.user == current_user || @friendship.friend == current_user
      friend = @friendship.user == current_user ? @friendship.friend : @friendship.user
      Friendship.where(user_id: current_user.id, friend_id: friend.id)
                .or(Friendship.where(user_id: friend.id, friend_id: current_user.id))
                .destroy_all
      redirect_to profile_path(current_user), notice: "Ami retiré."
    else
      redirect_to profile_path(current_user), alert: "Action non autorisée."
    end
  end

  private

  def set_friendship
    @friendship = Friendship.find(params[:id])
  end
end
