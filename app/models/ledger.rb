class Ledger < ActiveRecord::Base
  has_many :splits
end
