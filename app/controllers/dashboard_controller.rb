class DashboardController < ApplicationController
  def index
    @current_days = params[:days].to_i
    @start_date = @current_days.days.ago

    @days = [7, 30, 60, 180]
    (@days << @current_days).sort! unless @days.include?(@current_days)

    @expenses = @user.ledgers.expenses.approved_entries_since(@start_date)
    @daily_entries = 
      @user.entries.since(@start_date).approved.group_by(&:posted)
  end

end
