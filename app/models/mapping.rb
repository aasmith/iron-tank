class Mapping < ActiveRecord::Base
  EQUALS = "equals".freeze
  BEGINS = "begins".freeze
  CONTAINS = "contains".freeze

  belongs_to :ledger

  def match?(str)
    str.present? and equals?(str) || begins?(str) || contains?(str)
  end

  def equals?(str)
    value == str
  end

  def begins?(str)
    value =~ /^#{str}/
  end

  def contains?(str)
    value.include? str
  end

end
