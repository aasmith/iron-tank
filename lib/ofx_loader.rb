class OfxLoader
  class << self
    def load_ofx!(user, raw_ofx)
      parsed_ofx = OfxParser::OfxParser.parse(raw_ofx) or raise OfxParserError
      ledger = find_ledger(user, parsed_ofx)

    end

    def find_ledger(user, ofx)
      fid = ofx.sign_on.institute.id

      ofx.accounts.each do |acct|
        acct_num = acct.number
        routing_num = acct.routing_number

        ledger = user.ledgers.find(:first, :conditions => {
          :account_number => acct_num,
          :routing_number => routing_num,
          :fid => fid
        })

        return ledger if ledger
      end
      
      raise LedgerNotFound
    end
  end

  class LedgerNotFound < StandardError
  end

  class OfxParserError < StandardError
  end
end
