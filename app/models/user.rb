# == Schema Information
# Schema version: 20090227093920
#
# Table name: users
#
#  id         :integer         not null, primary key
#  username   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  has_many :ledgers
  
  %w(accounts categories expenses).each do |t|
    has_many t.to_sym, :conditions => { :type => t.classify }
  end

  has_many :keychains

  has_many :mappings, :through => :ledgers
  has_many :splits, :through => :ledgers
  has_many :entries, :order => "posted DESC"

  # Finds ledgers for the current user by checking the user's mappings.
  def ledgers_by_alias(name)
    strategies = [
      lambda { 
        mapping = mappings.detect { |mapping| mapping.match?(name) }
        mapping && mapping.ledger
      },
      lambda { ledgers.find_by_name(name.titleize) },
      lambda { ledgers.find_by_name(name) }
    ]

    # iterate through each strategy and execute, until one returns one or more ledgers.
    strategies.each do |s| 
      ledgers = s.call
      return ledgers if ledgers.present?
    end

    return nil
  end

  # Finds or creates a ledger of the given name (titleized).
  def ledgers_by_alias!(name)
    ledgers_by_alias(name) || expenses.create!(:name => name.titleize)
  end
end
