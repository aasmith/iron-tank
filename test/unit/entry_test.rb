require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "sum of all splits must equal zero" do
    e = Entry.new
    e.splits << Split.new(:amount => 100, :ledger => Account.new)
    e.splits << Split.new(:amount => -99, :ledger => Account.new)
    assert !e.valid?

    e.splits << Split.new(:amount => -1, :ledger => Account.new)
    assert e.valid?
  end

  test "must have one and only one opposite sign" do
    e = Entry.new
    e.splits << Split.new(:amount => 50, :ledger => Account.new)
    e.splits << Split.new(:amount => 50, :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    assert !e.valid?

    e.splits.pop
    assert e.valid?
  end

  test "must have two or more splits" do
    e = Entry.new
    e.splits << Split.new(:amount => 1, :ledger => Account.new)
    assert !e.valid?

    e.splits << Split.new(:amount => -1, :ledger => Account.new)
    assert e.valid?
  end

  test "must not have any zero-value splits" do
    e = Entry.new
    e.splits << Split.new(:amount => 100, :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    e.splits << Split.new(:amount => 0, :ledger => Account.new)
    assert !e.valid?

    e.splits.pop
    assert e.valid?
  end

  test "cannot have entry composed entirely of categories" do
    e = Entry.new
    e.splits << Split.new(:amount => 100,  :ledger => Category.new)
    e.splits << Split.new(:amount => -100, :ledger => Expense.new)
    assert !e.valid?

    e.splits.last.ledger = Account.new
    assert e.valid?
  end

  test "entries categorized as expenses" do
    [Category, Expense].each do |c|
      e = Entry.new
      e.splits << Split.new(:amount => -100, :ledger => Account.new)
      e.splits << Split.new(:amount =>  100, :ledger => c.new)
      assert e.valid?

      assert e.expense?
      assert e.entry_type == :expense
    end
  end

  test "entries categorized as incomes" do
    e = Entry.new
    e.splits << Split.new(:amount => 100,  :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Category.new)
    assert e.valid?

    assert e.income?
    assert e.entry_type == :income
  end

  test "entries categorized as transfers" do
    e = Entry.new
    e.splits << Split.new(:amount => 100,  :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    assert e.valid?

    assert e.transfer?
    assert e.entry_type == :transfer
  end

  test "entries categorized as refunds" do
    e = Entry.new
    e.splits << Split.new(:amount => 100,  :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Expense.new)
    assert e.valid?

    assert e.refund?
    assert e.entry_type == :refund
  end

end
