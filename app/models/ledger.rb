# A Ledger is a logical group of entries. It can represent an account, asset,
# or a grouping, such as a category.
class Ledger < ActiveRecord::Base
  has_many :splits
  belongs_to :user

  def balance
    Money.new(splits.sum(:amount))
  end
end
