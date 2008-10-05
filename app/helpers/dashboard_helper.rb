module DashboardHelper
  def summarize_ledgers(ledgers)
    summary = ledgers.collect do |array_of_ledgers|
      next ["Transfer"] if array_of_ledgers.empty?
      array_of_ledgers.map(&:name)
    end.flatten.uniq
    
    capped = summary.cap(3)
    capped[-1] = "#{capped[-1]} Others" if capped.last.is_a? Numeric

    capped.join(", ")
  end

  def summarize_entry_amount(entry)
    entry.credits.sum(&:amount).format
  end

  def summarize_entry_type(entry)
    [entry.entry_type.capitalize, 
      if entry.transfer?
        ["from", entry.ledgers.debits.map(&:name), 
         "to", entry.ledgers.credits.map(&:name)]
      else
        if entry.income? || entry.refund? || entry.transfer?
          ["to", entry.ledgers.credits.map(&:name)]
        else
          ["from", entry.ledgers.debits.map(&:name)]
        end
      end
    ].join(" ")
  end

end
