module DashboardHelper
  def summarize_ledgers(ledgers)
    summary = ledgers.collect do |array_of_ledgers|
      array_of_ledgers.map(&:name)
    end.flatten.uniq
    
    capped = summary.cap(3)
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

end
