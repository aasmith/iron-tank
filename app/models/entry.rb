# == Schema Information
# Schema version: 20090227093920
#
# Table name: entries
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  entry_type :string(255)
#  posted     :date
#  memo       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :splits
  has_many :ledgers, :through => :splits

  %w(transfer expense income refund).each do |type|
    named_scope type.pluralize.to_sym, :conditions => {:entry_type => type}
  end

  named_scope :since, lambda { |date|
    { :conditions => ["posted > ?", date] }
  }

  validate :sum_of_all_splits_equal_zero
  validate :has_only_one_opposite_signed_split
  validate :has_two_or_more_splits
  validate :has_no_zero_value_splits
  validate :has_at_least_one_account_type_split
  validates_presence_of :entry_type, :posted

  before_validation :cache_entry_type!

  def posted=(date)
    self[:posted] = date.to_date if date
  end

  # Finds an Entry with the same amount, regardless of sign, 
  # within +/- 3 days of the current Entry.
  def doppleganger
    user.entries.find(:first, :include => :splits, 
      :conditions => [ "entries.posted < ? AND entries.posted > ?
        AND entries.id != ?  AND ABS(splits.amount) = ?",
      posted + 3.days, posted - 3.days, id,
      credits.sum(&:amount).cents
    ])
  end

  def joinable?(other_entry)
    ([entry_type, other_entry.entry_type] & %w(expense income)).size == 2
  end

  # Joins entries:
  #  Entry(from "Checking", to "ELECTRONIC WITHDRAWL")
  # and
  #  Entry(from "PAYMENT RECEIVED", to "Credit Card")
  #
  # to make:
  #
  # Entry(from "Checking", to "Credit Card")
  #
  def join!(other_entry)
    raise "Cannot be joined" unless joinable?(other_entry)

    o_accts, o_nonaccts = other_entry.splits.partition{|s| s.ledger === Account}
    accts, nonaccts = splits.partition{|s| s.ledger === Account}

    Entry.transaction do
      o_accts.zip(nonaccts).each do |acct, nonacct|
        nonacct.ledger = acct.ledger
        nonacct.save!
      end

      accts.zip(o_nonaccts).each do |acct, nonacct|
        nonacct.ledger = acct.ledger
        nonacct.save!
      end

      other_entry.save!
      save!
    end
  end

  def refund?
    debit_ledger.class == Expense && credit?(Account)
  end

  def transfer?
    debit?(Account) && credit?(Account)
  end

  def income?
    debit_ledger.class == Category && credit?(Account)
  end

  def expense?
    debit?(Account) && credit?(Category)
  end

  def debits
    splits.select{|s| s.amount.cents < 0 }
  end

  def credits
    splits.select{|s| s.amount.cents > 0 }
  end

  def debit_ledger
    debits.size > 0 && debits.first.ledger
  end

  def credit_ledger
    credits.size > 0 && credits.first.ledger
  end

  def debit?(type)
    debit_ledger.is_a? type
  end

  def credit?(type)
    credit_ledger.is_a? type
  end

  # Returns the ledgers for this entry that are on the 'remote' side
  # of the transaction. For instance, a transaction between Groceries
  # and Checking, would return the Groceries ledger. Transfers return
  # an empty array.
  def remote_ledgers
    remote_splits.collect(&:ledger)
  end

  def local_ledgers
    local_splits.collect(&:ledger)
  end

  def remote_splits
    income? || refund? ? debits : credits
  end

  def local_splits
    income? || refund? ? credits : debits
  end

  protected

  def cache_entry_type!
    self.entry_type = calc_entry_type
  end

  def calc_entry_type
    %w(transfer income expense refund).each do |t|
      return t if send("#{t}?")
    end
    nil
  end

  def splits_total_zero?
    splits.to_a.sum(&:amount).zero?
  end

  def too_many_debits_and_credits?
    debits.size > 1 && credits.size > 1
  end
  
  def contains_zero_value_split?
    splits.select{|s| s.amount.zero? }.size > 0
  end

  def has_account_split?
    splits.any?{|s| s.ledger === Account }
  end

  # Validation calls
  
  def has_at_least_one_account_type_split
    errors.add("Must have at least one account") unless has_account_split?
  end

  def has_no_zero_value_splits
    errors.add("Cannot have a split with amount of zero") if 
      contains_zero_value_split?
  end

  def has_two_or_more_splits
    errors.add("Need at least two splits") unless splits.size >= 2
  end

  def sum_of_all_splits_equal_zero
    errors.add("Sum of all splits must equal zero") unless splits_total_zero?
  end

  def has_only_one_opposite_signed_split
    errors.add("Cannot have more than one debit and more than one credit") if
     too_many_debits_and_credits?
  end

end
