# == Schema Information
# Schema version: 20090227093920
#
# Table name: adapters
#
#  id         :integer         not null, primary key
#  fetcher    :string(255)
#  loader     :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Adapter < ActiveRecord::Base
  def fetcher_class
  end
  
  def loader_class
  end
end
