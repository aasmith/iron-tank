require 'test_helper'

class YodleeConverterTest < ActiveSupport::TestCase
  test "convert" do
    yt = Yodlee::Transaction.new

    transactions = Converter::Yodlee.convert([yt])
    transactions.each { |t| assert_instance_of Loader::Transaction, t }
  end
end
