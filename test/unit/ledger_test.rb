require 'test_helper'

class LedgerTest < ActiveSupport::TestCase
  test "balance equals all splits" do
    ledgers.each do |ledger|
      assert_equal ledger.splits.map(&:amount).sum, ledger.balance
    end
  end

  test "activity_within" do
    ledgers = Ledger.activity_within(7.days.ago)
    
    ledgers.each do |ledger|
      assert ledger.entries.any?{|e| e.posted > 7.days.ago.to_date }
    end

    assert_equal ledgers.size, ledgers.uniq{|e| e.class}.size
  end
end
