class Entry < ActiveRecord::Base
  has_many :splits

  validate :sum_of_all_splits_equal_zero
  validate :has_only_one_opposite_signed_split
  validate :has_two_or_more_splits
  validate :has_no_zero_value_splits
  validate :credits_and_debits_of_same_type

  def transfer?

  end

  def income?
  end

  def expense?
  end

  def debits
    splits.select{|s| s.amount < 0 }
  end

  def credits
    splits.select{|s| s.amount > 0 }
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

  def credits_and_debits_match_type?
    [credits, debits].all? do |splits|
      splits.collect(&:ledger).collect(&:class).uniq.size == 1
    end
  end

  # Validation calls
  
  def credits_and_debits_of_same_type
    errors.add("Credits and Debits must be from the same ledger type") unless
      credits_and_debits_match_type?
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
