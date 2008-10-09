require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  def setup
    s = Sentry::SymmetricSentry.new
    @c = {:login => "metheuser", :pass => "logmein"}
    @e = s.encrypt_to_base64(@c.to_yaml)
  end

  def test_encrypt
    acct = ledgers(:checking)
    acct.credentials = @c
    acct.save!

    assert_equal @e, acct.encrypted_credentials, "should be encrypted"
  end

  def test_decrypt
    acct = ledgers(:checking)
    acct.encrypted_credentials = @e
    acct.save!

    acct.reload

    assert_equal @e, acct.encrypted_credentials
    assert_equal @c, acct.credentials
  end
end
