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

# An account represents a physical ledger that can send and receive payments,
# for example, checking, savings, credit card. For simpler accounts, such as 
# installment loans, use a Category instead.
class Account < Ledger

  def fetch!
    return unless keychain

    fetcher = "fetcher/#{adapter.fetcher}".camelize.constantize.new(keychain.details, external_id)
    account_transactions = fetcher.fetch

    loader = "loader/#{adapter.loader}".camelize.constantize.new(self)
    loader.load!(account_transactions)
  end

end
