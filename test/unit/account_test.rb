require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  def setup
    s = Sentry::SymmetricSentry.new
    @c = {:login => "metheuser", :pass => "logmein"}
  end

  test "encrypt" do
    acct = ledgers(:checking)
    acct.credentials = @c
    acct.save!

    encrypted = acct.connection.select_value(
      "select credentials from ledgers where id = #{acct.id}")

    decrypted = YAML.load(
      Sentry::SymmetricSentry.new.decrypt_from_base64(encrypted))

    assert_equal decrypted, acct.credentials
  end

  test "decrypt" do
    acct = ledgers(:checking)
    acct.credentials = @c
    acct.save!

    assert_equal @e, acct.instance_eval {
      read_attribute_before_type_cast(:credentials)
    }
    assert_equal @c, acct.credentials
  end

  test "uninitialized credentials are an empty hash" do
    acct = ledgers(:checking)

    assert !acct.new_record?
    assert_equal Hash.new, acct.credentials
    assert_nil acct.credentials[:foo]
  end

  test "uninitialized credentials are an emtpy hash on new instances" do
    acct = Account.new

    assert acct.new_record?
    assert_equal Hash.new, acct.credentials
  end

  test "hash access to credentials" do
    acct = ledgers(:checking)
    acct.credentials[:foo] = 123
    assert_equal 123, acct.credentials[:foo]
  end
end
