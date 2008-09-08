class User < ActiveRecord::Base
  has_many :ledgers

  # All the subclasses of Ledger. 
  # Useful when calling build/create on the association.
  has_many :categories
  has_many :expenses
  has_many :accounts

  has_many :mappings, :through => :ledgers
  has_many :splits, :through => :ledgers
  has_many :entries
end
