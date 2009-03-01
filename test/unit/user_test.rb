require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:andy)
  end

  test "finds existing ledger by mapping" do
    m = @user.mappings.first
    assert_equal m.ledger, @user.ledgers_by_alias(m.value)
  end

  test "finds existing ledger by name" do
    @user.expenses.create!(:name => name="Foo #{rand(56)}")

    assert_equal name, @user.ledgers_by_alias(name).name
  end

  test "finds existing ledger by titleized name" do
    name = "Auto Service"

    @user.expenses.create!(:name => name)

    assert_equal name, @user.ledgers_by_alias(name.upcase).name
  end

  test "creates new ledger with titleized name" do
    s = "CAR WASHES"

    assert_nil @user.ledgers_by_alias(s)

    ledger = @user.ledgers_by_alias!(s)
    assert_equal s.titleize, ledger.name
  end
end
