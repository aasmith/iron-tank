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

  has_many :mappings, :through => :ledgers
  has_many :splits, :through => :ledgers
  has_many :entries, :order => "posted DESC"
end
