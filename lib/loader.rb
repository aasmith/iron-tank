class Loader
  Transaction = Struct.new(:fit_id, :payee, :sic, :amount, :date, :currency)

  def initialize(ledger)
    @ledger = ledger
    @user   = ledger.user
  end

  def load!(transactions)
    transactions.each { |t| process_transaction(t) }
  end

  def process_transaction(transaction)
    # skip if this transaction's fit id matches any splits in the ledger
    return if @ledger.splits.exists?(:fit => transaction.fit_id)

    if $VERBOSE
      puts "-"*80
      pp transaction
    end

    # the non-bang call may return nil if no suitable
    # ledger is found
    derived_ledger = @user.ledgers_by_alias(
      transaction.sic || transaction.payee
    )

    derived_ledger ||= @user.unknown_ledger

    # create entry
    e = @user.entries.new(:posted => transaction.date)
    e.memo = transaction.payee

    # attach split for the current ledger.
    e.splits << @ledger.splits.create(
      :amount => Money.new(transaction.amount),
      :fit    => transaction.fit_id
    )

    # attach split for the opposite amount in the opposing ledger.
    e.splits << derived_ledger.splits.create(
      :amount => Money.new(transaction.amount.oppose),
      :fit    => transaction.fit_id
    )

    if $VERBOSE
      pp e
      pp e.splits
    end

    unless e.valid?
      pp e.errors
      return
    end

    e.save!

    d = e.doppleganger

    e.join!(d) if d && e.joinable?(d) 
  end
end
