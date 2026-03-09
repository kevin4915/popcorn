class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @top_week = Movie.order(rating: :desc).limit(10)
    @top_personal = Movie.joins(:historics).where(historics: { user_id: current_user.id }).order(rating: :desc).limit(10)
  end
end
