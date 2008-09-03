require 'test_helper'

class LedgerTest < ActiveSupport::TestCase
  test "balance equals all splits" do
    ledgers.each do |ledger|
      assert_equal ledger.splits.map(&:amount).sum, ledger.balance
    end
  end
end
