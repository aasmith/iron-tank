class Entry < ActiveRecord::Base
  has_many :splits

  validate :sum_of_all_splits_equal_zero
  validate :has_only_one_opposite_signed_split
  validate :has_two_or_more_splits
  validate :has_no_zero_value_splits
  validate :has_at_least_one_account_type_split

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

  def entry_type
    [:transfer, :income, :expense, :refund].each do |t|
      break t if send("#{t}?")
    end
  end

  def debits
    splits.select{|s| s.amount < 0 }
  end

  def credits
    splits.select{|s| s.amount > 0 }
  end

  def debit_ledger
    debits.first.ledger
  end

  def credit_ledger
    credits.first.ledger
  end

  def debit?(type)
    debit_ledger.is_a? type
  end

  def credit?(type)
    credit_ledger.is_a? type
  end

  protected

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
