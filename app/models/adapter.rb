# == Schema Information
# Schema version: 20090227093920
#
# Table name: adapters
#
#  id         :integer         not null, primary key
#  fetcher    :string(255)
#  converter  :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

# An Adapter represents the relationship between fetchers and converters.
class Adapter < ActiveRecord::Base
  has_many :ledgers

  %w(fetcher converter).each do |method|
    define_method :"#{method}_class" do
      "#{method}/#{attributes[method]}".camelize.constantize
    end
  end

end
