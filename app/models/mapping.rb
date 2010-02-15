# == Schema Information
# Schema version: 20091019043039
#
# Table name: mappings
#
#  id         :integer         not null, primary key
#  ledger_id  :integer
#  condition  :string(255)
#  value      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

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
