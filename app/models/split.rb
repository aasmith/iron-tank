# == Schema Information
# Schema version: 20090227093920
#
# Table name: splits
#
#  id         :integer         not null, primary key
#  entry_id   :integer
#  ledger_id  :integer
#  amount     :integer
#  fit        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

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
