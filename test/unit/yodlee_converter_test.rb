require 'test_helper'

class YodleeConverterTest < ActiveSupport::TestCase
  test "convert" do
    yt = Yodlee::Transaction.new
    yt.amount = 1.00 # $1

    transactions = Converter::Yodlee.convert([yt])

    transactions.each { |t| 
      assert_instance_of Loader::Transaction, t
      assert_equal 100, t.amount
    }
  end
end
