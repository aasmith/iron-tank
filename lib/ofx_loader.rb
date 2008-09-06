class OfxLoader
  class << self
    def load_ofx!(user, raw_ofx)
      parsed_ofx = OfxParser::OfxParser.parse(raw_ofx) or raise OfxParserError
      ledger = find_ledger(user, parsed_ofx)
      
      ofx_account = parsed_ofx.accounts.first
      ofx_account.statement.transactions.each do |transaction|
        next if ledger.splits.exists?(:fit => entry.fit)
        
        amount = transaction.amount_in_pennies
        sic_desc = transaction.sic_desc rescue nil
        derived_ledger = derive_ledger(user, payee, sic_desc)

        e = Entry.new
        e.memo = transaction.payee
        e.splits << ledger.splits.build(:amount => amount)
        e.splits << derived_ledger.splits.build(:amount => amount.oppose)

        next if e.doppleganger 

        e.save!
      end
    end

    def find_ledger(user, ofx)
      fid = ofx.sign_on.institute.id

      # There should only be one account. 
      # This is is a TODO in ofx-parser.
      acct = ofx.accounts.first
      acct_num = acct.number
      routing_num = acct.routing_number

      user.ledgers.find(:first, :conditions => {
        :account_number => acct_num,
        :routing_number => routing_num,
        :fid => fid
      }) or raise LedgerNotFound
    end

    def derive_ledger(user, payee, sic = nil)
      if payee.blank? && sic.blank?
        return user.ledgers.find_or_create_by_name("Unknown")
      end

      # * lookup by mapping
      mapping = user.mappings.detect{|m| m.match?(payee) }
      return mapping.ledger if mapping

      # * OR lookup by sic 
      ledger = user.ledgers.find_by_name(pretty_sic(sic)) if sic
      return ledger if ledger

      # * OR lookup by exact payee
      ledger = user.ledgers.find_by_name(payee)
      return ledger if ledger

      # * OR create based on sic (TODO)
      ledger = user.ledgers.create!(:name => pretty_sic(sic)) if sic
      return ledger if ledger

      # * OR create based on exact payee
      user.ledgers.create!(:name => payee)
    end

    # change a SHOUTY SIC DESCRIPTION into A Nice Readable One.
    def pretty_sic(sic)
      sic.humanize.split.map(&:capitalize).join(" ")
    end

  end

  class LedgerNotFound < StandardError
  end

  class OfxParserError < StandardError
  end
end