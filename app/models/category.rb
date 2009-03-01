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
#  external_id :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

# A category is a type of ledger that can only make or receive payments 
# to accounts, not other categories. This should also be used for simple
# accounts, such as installment loans. 
class Category < Ledger
end
