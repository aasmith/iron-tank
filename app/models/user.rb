class User < ActiveRecord::Base
  has_many :ledgers
end
