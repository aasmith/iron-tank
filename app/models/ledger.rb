# A Ledger is a logical group of entries. It can represent an account, asset,
# or a grouping, such as a category.
class Ledger < ActiveRecord::Base
  has_many :splits do
    def balance
      Money.new(sum(:amount))
    end
  end

  has_many :entries, :through => :splits
  has_many :mappings
  belongs_to :user

  %w(accounts categories expenses).each do |t|
    named_scope t.to_sym, :conditions => {:type => t.classify}
  end

  named_scope :approved_entries_since, lambda { |date|
    { :conditions => ["entries.posted > ? AND 
                       entries.approved = ?", date, true], 
      :include => :entries }
  }

  named_scope :credits, 
    :conditions => ["splits.amount > 0"], 
    :include => :splits
  
  named_scope :debits, 
    :conditions => ["splits.amount < 0"], 
    :include => :splits

  validates_presence_of :type

  def balance
    splits.balance
  end
end

