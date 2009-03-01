require 'test_helper'

class LoaderTest < ActiveSupport::TestCase
  def setup
    @user = users(:andy)
    @account = @user.accounts.detect{|a| a.entries.present? } # find a ledger that isnt empty
    @loader = Loader.new(@account)

    @transaction = Loader::Transaction.new
    @transaction.amount = -123_45
    @transaction.payee = "Bob's Fish"
    @transaction.date = Date.yesterday
    @transaction.sic = "FISHMONGERS"
    @transaction.fit_id = "blah"
  end

  test "process_transaction skips on existing transaction" do
    before_s = @account.splits.size
    before_e = @account.entries.size

    split = @account.splits.first
    split.fit = "blah"
    split.save!

    @loader.process_transaction(@transaction)

    assert_equal before_s, @account.splits.size, "no splits should have been added"
    assert_equal before_e, @account.entries.size, "no entries should have been added"
  end

  test "process_transaction uses sic code" do
    # match SIC code on transaction
    process_transaction_with_expense_name("Fishmongers")
  end

  test "process_transaction uses payee name" do
    @transaction.sic = nil

    process_transaction_with_expense_name("Bob's Fish")
  end

  def process_transaction_with_expense_name(name)
    new_expense = @user.expenses.create!(:name => name)

    current_entries = @account.entries
    assert_equal 0, new_expense.entries.size

    @loader.process_transaction(@transaction)

    @account.reload
    new_expense.reload

    # The spending account, as well as the new 
    # expense ledger should have this new entry
    assert_equal current_entries.size + 1, @account.entries.size
    assert_equal 1, new_expense.entries.size

    new_entry = (@account.entries - current_entries).first

    assert new_entry.expense?
    assert_equal @account, new_entry.debit_ledger
    assert_equal new_expense, new_entry.credit_ledger
    assert_equal @transaction.payee, new_entry.memo
    assert_equal @transaction.date, new_entry.posted
    assert_equal 123_45, new_entry.credits.sum(&:amount).cents
    assert_equal -123_45, new_entry.debits.sum(&:amount).cents
    assert_equal "blah", new_entry.splits.map(&:fit).uniq.to_s
  end
end
