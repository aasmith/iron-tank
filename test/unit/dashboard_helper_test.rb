require 'test_helper'

class DashboardHelperTest < ActionView::TestCase
  tests DashboardHelper

  test "summarize_ledgers" do
    array = [
      [Ledger.new(:name => "A"), Ledger.new(:name => "B")], 
      [Ledger.new(:name => "A"), Ledger.new(:name => "D")], 
      [Ledger.new(:name => "A")]] 

    assert_equal "A, B, D", summarize_ledgers(array)
    
    array << [Ledger.new(:name => "C")]

    assert_equal "A, B, 2 Others", summarize_ledgers(array)
  end

end
