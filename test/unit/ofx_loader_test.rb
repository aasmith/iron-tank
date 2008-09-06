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

  test "derives existing ledger by mapping" do
    m = Mapping.find_by_condition(Mapping::EQUALS)

    assert_equal m.ledger, OfxLoader.derive_ledger(m.ledger.user, m.value)
  end

  test "derives existing ledger by payee" do
    users(:andy).ledgers.create!(:name => name="Foo #{rand(56)}")

    assert_equal name, OfxLoader.derive_ledger(users(:andy), name).name
  end

  test "derives existing ledger by SIC" do
    users(:andy).ledgers.create!(:name => name="Auto Service")

    assert_equal name, OfxLoader.derive_ledger(users(:andy), "", name).name
  end

  test "derives new ledger by SIC" do
    s = "CAR WASHES"
    u = users(:andy)

    assert_nil u.ledgers.find_by_name(OfxLoader.pretty_sic(s))
    OfxLoader.derive_ledger(u, "", s)
    assert_equal "Car Washes", u.ledgers.find_by_name("Car Washes").name
  end

  test "derives new ledger by payee name" do
    p = "Duff Pizza, Inc."
    u = users(:andy)

    assert_nil u.ledgers.find_by_name(p)
    OfxLoader.derive_ledger(u, p)
    assert_equal p, u.ledgers.find_by_name(p).name
  end

  test "derive returns unknown ledger when no payee or sic" do
    assert_equal "Unknown", OfxLoader.derive_ledger(users(:andy), "", nil).name 
  end

  test "pretty_sic" do
    assert_equal "Bowling Alleys", OfxLoader.pretty_sic("BOWLING ALLEYS")
  end

end
