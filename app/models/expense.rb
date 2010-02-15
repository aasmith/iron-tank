# == Schema Information
# Schema version: 20091019043039
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

# An expense is a more specific type of category for tracking types
# of outgoing expenses, such as Clothing, Groceries, etc.
class Expense < Category
end
