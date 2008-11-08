class Split < ActiveRecord::Base
  belongs_to :entry
  belongs_to :ledger

  named_scope :since, lambda { |date|
    { :conditions => ["entries.posted > ?", date], :include => :entry }
  }

  composed_of(:amount, 
    :class_name => "Money", 
    :mapping => %w(amount cents),
    :converter => lambda{|amt| amt.to_money})
end
