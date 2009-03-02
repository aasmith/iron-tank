# == Schema Information
# Schema version: 20090227093920
#
# Table name: ledgers
#
#  id          :integer         not null, primary key
#  type        :string(255)
#  name        :string(255)
#  user_id     :integer
#  keychain_id :integer
#  adapter_id  :integer
#  external_id :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

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
  belongs_to :keychain
  belongs_to :adapter

  # Avoid using this named_scope because it points to STI
  # subclasses, which break when using create, etc.:
  #
  # Consider: @user.ledgers.expenses.create!(...).class
  # Expect: Expense, got Ledger.
  #
  # %w(accounts categories expenses).each do |t|
  #   named_scope t.to_sym, :conditions => {:type => t.classify}
  # end

  named_scope :entries_since, lambda { |date|
    { :conditions => ["entries.posted > ? ", date], 
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

