# A Ledger is a logical group of entries. It can represent an account, asset,
# or a grouping, such as a category.
class Ledger < ActiveRecord::Base
  has_many :splits
  has_many :entries, :through => :splits
  has_many :mappings
  belongs_to :user

  validates_presence_of :type, :allow_nils => false

  def balance
    Money.new(splits.sum(:amount))
  end
end
