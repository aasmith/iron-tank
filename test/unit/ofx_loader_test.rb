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
    users(:andy).ledgers.expenses.create!(:name => name="Foo #{rand(56)}")

    assert_equal name, OfxLoader.derive_ledger(users(:andy), name).name
  end

  test "derives existing ledger by SIC" do
    users(:andy).ledgers.expenses.create!(:name => name="Auto Service")

    assert_equal name, OfxLoader.derive_ledger(users(:andy), "", name).name
  end

  test "derives new ledger by SIC" do
    s = "CAR WASHES"
    u = users(:andy)

    assert_nil u.ledgers.find_by_name(s.titleize)
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

  test "loading ofx doesnt add duplicates" do
    ofx = File.read("#{RAILS_ROOT}/test/fixtures/ofx/andy-creditcard.ofx")
    ledger = Ledger.find_by_fid("789")
    before = ledger.entries.size

    OfxLoader.load_ofx!(users(:andy), ofx)
    after = ledger.entries.size

    assert after > before, "should have added at least one entry"

    OfxLoader.load_ofx!(users(:andy), ofx)
    assert_equal after, ledger.entries.size, "should be no more entries"
  end

  test "load ofx creates a transfer" do
    # this test relies on certain entries in the banking and credit-card ofx.
    ofx = File.read("#{RAILS_ROOT}/test/fixtures/ofx/andy-creditcard.ofx")
    OfxLoader.load_ofx!(users(:andy), ofx)

    split = Ledger.find_by_fid("789").splits.find_by_fit("78-9")

    assert_equal "income", split.entry.entry_type, 
      "should not have been matched with a doppleganger"
    
    ofx = File.read("#{RAILS_ROOT}/test/fixtures/ofx/andy-banking.ofx")
    OfxLoader.load_ofx!(users(:andy), ofx)

    split.reload
    assert_equal "transfer", split.entry.entry_type
    
    other_split = Ledger.find_by_fid("123").splits.find_by_fit("11 22")
    assert_equal "transfer", other_split.entry.entry_type
  end

end
