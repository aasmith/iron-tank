# A Ledger is a logical group of entries. It can represent an account, asset,
# or a grouping, such as a category.
class Ledger < ActiveRecord::Base
  has_many :splits
  has_many :entries, :through => :splits
  has_many :mappings
  belongs_to :user

  %w(categories expenses transfers).each do |t|
    named_scope t.to_sym, :conditions => {:type => t.classify}
  end

  validates_presence_of :type

  def balance
    Money.new(splits.sum(:amount))
  end
end
