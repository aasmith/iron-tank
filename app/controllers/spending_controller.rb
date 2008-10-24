class SpendingController < ApplicationController

  before_filter :init_day_params, :only => [:category, :day]

  def category
    @expenses = 
      @user.ledgers.expenses.entries_since(@start_date).collect do |expense|
        [expense, expense.splits.since(@start_date)]
      end
  end

  def day
    @period = @current_days > 14 ? :weekly : :daily

    @daily_entries = 
      @user.entries.since(@start_date).group_by do |e|
        @period == :weekly ? e.posted.beginning_of_week : e.posted
      end
  end

  def edit_split_ledgers
    entry = @user.entries.find(params[:entry_id])

    Entry.transaction do
      params[:split].each do |split_id, values|
        split = entry.splits.find(split_id)
        split.ledger = @user.ledgers.find(values[:ledger_id])
        split.save!
      end

      entry.save!
    end

    render(:update) do |page|
      page["entry-#{entry.id}"].replace :partial => "entry", :object => entry
      page["entry-edit#{entry.id}"].replace :partial => "entry", :locals => {:entry => entry}
      page["entry-#{entry.id}"].visual_effect :highlight
      page.call 'initLedgerSelectors'
    end
  end

  private

  def init_day_params
    @current_days = params[:days].to_i
    @start_date = @current_days.days.ago

    @days = [7, 30, 60, 180]
    (@days << @current_days).sort! unless @days.include?(@current_days)
  end

end
