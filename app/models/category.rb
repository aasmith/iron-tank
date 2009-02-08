# == Schema Information
# Schema version: 20080904073207
#
# Table name: ledgers
#
#  id             :integer         not null, primary key
#  type           :string(255)
#  name           :string(255)
#  user_id        :integer
#  fid            :string(255)
#  institution    :string(255)
#  account_number :string(255)
#  routing_number :string(255)
#  credentials    :text
#  created_at     :datetime
#  updated_at     :datetime
#

# A category is a type of ledger that can only make or receive payments 
# to accounts, not other categories. This should also be used for simple
# accounts, such as installment loans. 
class Category < Ledger
end
