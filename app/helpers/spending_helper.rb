module SpendingHelper
  def summarize_ledgers(ledgers)
    summary = ledgers.collect do |array_of_ledgers|
      array_of_ledgers.map(&:name)
    end.flatten.uniq

    cap(summary, 3)
  end

  # returns an array of ledgers, ordered by highest to lowest spend
  def summarize_ledgers_by_spending(entries)
    ledger_spending = Hash.new(0)

    entries.each do |entry|
      next if entry.transfer?

      entry.remote_splits.each do |split|
        ledger_spending[split.ledger] += split.amount.cents.abs
      end
    end

    cap(ledger_spending.sort_by(&:last).reverse.map(&:first).map(&:name), 5)
  end

  def cap(array, limit)
    capped = array.cap(limit)
    capped[-1] = "#{capped[-1]} Others" if capped.last.is_a? Numeric

    capped.join(", ")
  end

  def summarize_entry_amount(entry)
    entry.credits.sum(&:amount).format
  end

  def net_gain(entries)
    exp = entries.select(&:expense?)
    inc = entries.select{|e| e.refund? || e.income? }

    exp.map(&:debits).flatten.sum(&:amount).to_money +
    inc.map(&:credits).flatten.sum(&:amount).to_money
  end

  def ledger_selection_for_splits(splits)
    splits.collect do |split|
      s = []
      s << select_tag("split[#{split.id}][ledger_id]", 
                      options_for_select(
                        @user.ledgers.map{|e|[e.name,e.id]}, split.ledger.id))
      s << split.amount.format if splits.size > 1
      s.join
      content_tag "div", s, :class => "split"
    end
  end

  def more_or_less(value, baseline)
    amount = Money.new((value.cents - baseline.cents).abs).format(:no_cents)
    more_or_less = value > baseline ? "more" : "less"

    content_tag(:span, "#{amount} #{more_or_less}", :class => more_or_less)
  end
end
