module Converter
  class Ofx
    def self.convert(raw_ofx)
      parsed_ofx = OfxParser::OfxParser.parse(raw_ofx) or raise OfxParserError
      raise "blank ofx" if parsed_ofx.blank?

      ofx_account = parsed_ofx.accounts.first

      ofx_account.statement.transactions.map do |ofx_transaction|
        t = Loader::Transaction.new
        t.date     = ofx_transaction.date
        t.fit_id   = ofx_transaction.fit_id
        t.payee    = ofx_transaction.payee
        t.sic      = ofx_transaction.sic_desc
        t.amount   = ofx_transaction.amount_in_pennies
        t.currency = ofx_account.statement.currency
        t
      end
    end

    class OfxParserError < StandardError
    end
  end
end
