class User < ActiveRecord::Base
  has_many :ledgers
  has_many :mappings, :through => :ledgers
end
