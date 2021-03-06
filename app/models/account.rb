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

# An account represents a physical ledger that can send and receive payments,
# for example, checking, savings, credit card. For simpler accounts, such as 
# installment loans, use a Category instead.
class Account < Ledger

  def fetch!(details)
    fetcher = adapter.fetcher_class.new(details, external_id)
    details = nil
    account_transactions = fetcher.fetch

    converter = adapter.converter_class
    transactions = converter.convert(account_transactions)

    loader = Loader.new(self)
    loader.load!(transactions)
  end

end
