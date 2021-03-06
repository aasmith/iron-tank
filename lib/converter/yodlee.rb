module Converter
  class Yodlee
    def self.convert(yodlee_transactions)
      yodlee_transactions.map do |yt|
        t = Loader::Transaction.new

        (t.members - %w(amount payee sic)).each do |attr|
          t.send(:"#{attr}=", yt.send(attr))
        end

        t.amount = yt.amount * 100
        t.payee  = yt.description

        t
      end
    end
  end
end

