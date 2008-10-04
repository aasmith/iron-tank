class DashboardController < ApplicationController
  def index
    @current_days = params[:days].to_i

    @days = [7, 30, 60, 180]
    (@days << @current_days).sort! unless @days.include?(@current_days)
  end

end
