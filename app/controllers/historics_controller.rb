class HistoricsController < ApplicationController
  def index
    @historics = current_user.movies.order(created_at: :desc)
  end
end
