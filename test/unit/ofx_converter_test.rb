require 'test_helper'

class OfxConverterTest < ActiveSupport::TestCase
  CC_OFX = File.read("#{File.dirname(__FILE__)}/../fixtures/ofx/andy-creditcard.ofx")

  test "convert" do
    transactions = Converter::Ofx.convert(CC_OFX)
    transactions.each { |t| assert_instance_of Loader::Transaction, t }
  end
end
