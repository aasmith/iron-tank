# A Ledger is a logical group of entries. It can represent an account, asset,
# or a grouping, such as a category.
class Ledger < ActiveRecord::Base
  has_many :splits
  has_many :entries, :through => :splits
  has_many :mappings
  belongs_to :user

  %w(categories expenses).each do |t|
    named_scope t.to_sym, :conditions => {:type => t.classify}
  end

  named_scope :activity_since, lambda { |date|
    { :conditions => ["entries.posted > ?", date], :include => :entries }
  }

  validates_presence_of :type

  def balance
    Money.new(splits.sum(:amount))
  end
end

