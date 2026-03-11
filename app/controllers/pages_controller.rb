class PagesController < ApplicationController
  def home
    @top_week = Movie.order(rating: :desc).limit(10) || []
    @top_personal = current_user ? Movie.joins(:historics).where(historics: { user_id: current_user.id }).order(rating: :desc).limit(10) : []
  end
end
