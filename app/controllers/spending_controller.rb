class SpendingController < ApplicationController

  def category
    time_ranges = 4.downto(0).map{|n| [n.months.ago.beginning_of_month, n.months.ago.end_of_month]}

    expenses = @user.expenses.excluding(@user.unknown_ledger).with_entries_since(2.months.ago).map do |expense|

      totals  = time_ranges.map { |from, to| Money.new(expense.entries.between(from, to).sum(:amount).to_i) }
      entries = time_ranges.map { |from, to| expense.entries.between(from, to) }

      current_entries = entries.last
      current_total = totals.last

      # dont include the current period in the average. it is probably lower
      # because we are not all the way through it.
      average = totals[0,totals.size-1].reduce(:+) / (totals.size - 1)
      
      winner = current_total <= average 
      deviation = (current_total.floor - average.floor)

      {
        :expense => expense, 
        :totals => totals, 
        :entries => entries,
        :current_total => current_total,
        :average => average, 
        :winner => winner, 
        :deviation => deviation,
        :current_entries => current_entries
      }
    end

    @winners = []
    @losers = [] 
    @others = []

    expenses.sort_by{ |h| h[:deviation].cents.abs }.reverse.each do |h|
      if !h[:winner] && !h[:current_total].zero?
        @losers << h
      elsif h[:winner] && !h[:current_total].zero?
        @winners << h
      else
        @others << h
      end
    end
  end

end
