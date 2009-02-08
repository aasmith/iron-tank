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

# An expense is a more specific type of category for tracking types
# of outgoing expenses, such as Clothing, Groceries, etc.
class Expense < Category
end
