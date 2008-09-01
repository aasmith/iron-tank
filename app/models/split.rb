class Split < ActiveRecord::Base
  belongs_to :entry
  belongs_to :ledger

  composed_of(:amount, 
    :class_name => "Money", 
    :mapping => %w(cents cents)) {|amt| amt.to_money}
end
