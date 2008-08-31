class Split < ActiveRecord::Base
  belongs_to :entry
  belongs_to :ledger
end
