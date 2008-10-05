class User < ActiveRecord::Base
  has_many :ledgers

  has_many :mappings, :through => :ledgers
  has_many :splits, :through => :ledgers
  has_many :entries, :order => "posted DESC"
end
