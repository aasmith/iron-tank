require 'test_helper'

class OfxLoaderTest < ActiveSupport::TestCase
  CC_OFX = File.read(
    "#{File.dirname(__FILE__)}/../fixtures/ofx/andy-creditcard.ofx")

  test "finds ledger" do
    ofx = OfxParser::OfxParser.parse(CC_OFX)
    ledger = OfxLoader.find_ledger(users(:andy), ofx)

    ofx_acct = ofx.accounts.first

    assert_equal users(:andy), ledger.user
    assert_equal ofx_acct.number, ledger.account_number
    assert_equal ofx_acct.routing_number, ledger.routing_number
    assert_equal ofx.sign_on.institute.id, ledger.fid
  end

  test "doesnt find ledger" do
    ofx = OfxParser::OfxParser.parse(CC_OFX)
    ofx.sign_on.institute.id = 83243264275649

    assert_raise(OfxLoader::LedgerNotFound) {
      OfxLoader.find_ledger(users(:andy), ofx)
    }
  end

  test "creates entries" do
    return
    OfxLoader.load_ofx!(users(:andy), CC_OFX)

    cc = ledgers(:credit_card)
  end

end
