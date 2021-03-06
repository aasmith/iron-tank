require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class EntryTest < ActiveSupport::TestCase
  test "fixtures valid" do
    assert Entry.all.all?(&:valid?)
  end

  test "sum of all splits must equal zero" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 100, :ledger => Account.new)
    e.splits << Split.new(:amount => -99, :ledger => Account.new)
    assert !e.valid?

    e.splits << Split.new(:amount => -1, :ledger => Account.new)
    assert e.valid?
  end

  test "must have one and only one opposite sign" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 50, :ledger => Account.new)
    e.splits << Split.new(:amount => 50, :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    assert !e.valid?

    e.splits.pop
    assert e.valid?
  end

  test "must have two or more splits" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 1, :ledger => Account.new)
    assert !e.valid?

    e.splits << Split.new(:amount => -1, :ledger => Account.new)
    assert e.valid?
  end

  #test "must not have any zero-value splits" do
  #  e = Entry.new(:posted => Date.today)
  #  e.splits << Split.new(:amount => 100, :ledger => Account.new)
  #  e.splits << Split.new(:amount => -100, :ledger => Account.new)
  #  e.splits << Split.new(:amount => 0, :ledger => Account.new)
  #  assert e.valid?

  #  e.splits.pop
  #  assert e.valid?
  #end

  test "cannot have entry composed entirely of categories" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 100,  :ledger => Category.new)
    e.splits << Split.new(:amount => -100, :ledger => Expense.new)
    assert !e.valid?

    e.splits.last.ledger = Account.new
    assert e.valid?
  end

  test "entries categorized as expenses" do
    [Category, Expense].each do |c|
      e = Entry.new(:posted => Date.today)
      e.splits << Split.new(:amount => -100, :ledger => Account.new)
      e.splits << Split.new(:amount =>  100, :ledger => c.new)
      assert e.valid?

      assert e.expense?
      assert e.entry_type == "expense"
    end
  end

  test "entries categorized as incomes" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 100,  :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Category.new)
    assert e.valid?

    assert e.income?
    assert e.entry_type == "income"
  end

  test "entries categorized as transfers" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 100,  :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Account.new)
    assert e.valid?

    assert e.transfer?
    assert e.entry_type == "transfer"
  end

  test "entries categorized as refunds" do
    e = Entry.new(:posted => Date.today)
    e.splits << Split.new(:amount => 100,  :ledger => Account.new)
    e.splits << Split.new(:amount => -100, :ledger => Expense.new)
    assert e.valid?

    assert e.refund?
    assert e.entry_type == "refund"
  end

  test "finds dopplegangers given an existing entry" do
    e = entries(:pay_cc)
    e.posted = 2.days.ago
    e.save!

    assert_nil e.doppleganger

    s1, s2 = e.splits

    d = users(:andy).entries.new
    d.posted = Date.today
    d.splits << Split.new(:amount => s1.amount, :ledger => s2.ledger)
    d.splits << Split.new(:amount => s2.amount, :ledger => s1.ledger)
    d.save!

    assert e.doppleganger

    d.posted = 3.weeks.ago
    d.save!

    assert_nil e.doppleganger
  end

  test "joinable should only work for income/expense" do
    a = Entry.new; a.entry_type = "income"
    b = Entry.new; b.entry_type = "expense"
    assert a.joinable?(b)

    %w(transfer refund income expense).each do |t|
      %w(transfer refund income expense).each do |t2|
        a.entry_type = t
        b.entry_type = t2

        unless t == "expense" && t2 == "income" or
               t == "income"  && t2 == "expense"
          assert !a.joinable?(b), "#{t}, #{t2} should not be joinable"
        end
      end
    end
  end

  test "join" do

    # Simulates a transaction from checking to the "PAYMENT THANK YOU" payee
    u = users(:andy)
    e = u.entries.build(:posted => 2.days.ago)

    ck = ledgers(:checking)
    cc = ledgers(:credit_card)
    
    crd = Category.create!(:user => u, :name => "PAYMENT THANK YOU")
    deb = Category.create!(:user => u, :name => "ELECTRONIC WITHDRAWL")

    e.splits.build(:amount =>  100, :ledger => deb)
    e.splits.build(:amount => -100, :ledger => ck)
    e.save!

    assert_nil e.doppleganger

    # Simulates a transaction from "FUNDS TRANSFER" to credit card
    d = u.entries.build(:posted => 1.days.ago)
    d.splits << Split.new(:amount => -100, :ledger => crd)
    d.splits << Split.new(:amount =>  100, :ledger => cc)
    d.save!

    assert_equal d, e.doppleganger
    assert e.joinable?(d)

    e.join!(d)

    e.reload

    assert_equal 2, e.splits.size

    assert e.splits.all?{|s|s.ledger === Account}

    assert e.splits.any?{|s|s.ledger == ck}
    assert e.splits.any?{|s|s.ledger == cc}

    assert d.frozen?, "other entry should be deleted"
  end

  test "remote_ledgers return Expenses or Categories for everything else" do
    Entry.all.each do |entry|
      unless entry.transfer?
        assert !entry.remote_ledgers.empty?

        entry.remote_ledgers.each {|ledger|
          assert [Expense, Category].include?(ledger.class)
        }
      end
    end
  end

end
