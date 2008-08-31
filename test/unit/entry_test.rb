require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "sum of all splits must equal zero" do
    e = Entry.new
    e.splits << Split.new(:amount => 100)
    e.splits << Split.new(:amount => -99)
    assert !e.valid?

    e.splits << Split.new(:amount => -1)
    assert e.valid?
  end

  test "must have one and only one opposite sign" do
    e = Entry.new
    e.splits << Split.new(:amount => 50)
    e.splits << Split.new(:amount => 50)
    e.splits << Split.new(:amount => -100)
    e.splits << Split.new(:amount => -100)
    assert !e.valid?

    e.splits.pop
    assert e.valid?
  end

  test "must have two or more splits" do
    e = Entry.new
    e.splits << Split.new(:amount => 1)
    assert !e.valid?

    e.splits << Split.new(:amount => -1)
    assert e.valid?
  end

  test "must not have any zero-value splits" do
    e = Entry.new
    e.splits << Split.new(:amount => 100)
    e.splits << Split.new(:amount => -100)
    e.splits << Split.new(:amount => 0)
    assert !e.valid?

    e.splits.pop
    assert e.valid?
  end

  test "all credits and debits must be of the same ledger type" do
    a = Asset.new
    b = Liability.new

    e = Entry.new
    e.splits << Split.new(:amount => -200, :ledger => a)
    e.splits << Split.new(:amount => 100,  :ledger => b)
    e.splits << Split.new(:amount => 100,  :ledger => a)
    assert !e.valid?

    e.splits.last.ledger = b
    assert e.valid?
  end

  test "transfers must be only a transfer" do
    a = Asset.new
    e = Entry.new
    e.splits << Split.new(:amount => 1, :ledger => a)
    e.splits << Split.new(:amount => -1, :ledger => a)

    assert e.valid?
    assert e.transfer?
    assert e.entry_type == :transfer

    [:income?, :expense?].each{|t| assert !e.send(t)}
  end

  test "income must be only income" do
    a = Asset.new
    b = Liability.new
    e = Entry.new
    e.splits << Split.new(:amount => 2,  :ledger => a)
    e.splits << Split.new(:amount => -2, :ledger => b)

    assert e.valid?
    assert e.income?
    assert e.entry_type == :income

    [:transfer?, :expense?].each{|t| assert(!e.send(t)) }
  end
  
  test "expense must be only expense" do
    a = Asset.new
    b = Liability.new
    e = Entry.new
    e.splits << Split.new(:amount => -2,  :ledger => a)
    e.splits << Split.new(:amount => 2, :ledger => b)

    assert e.valid?
    assert e.expense?
    assert e.entry_type == :expense

    [:transfer?, :income?].each{|t| assert(!e.send(t)) }
  end
end
