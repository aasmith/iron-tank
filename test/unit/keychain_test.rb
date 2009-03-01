require 'test_helper'

class KeychainTest < ActiveSupport::TestCase
  test "details get encrypted" do
    d = {:secret => "foo", :secret2 => "bar"}
    key = "somekey"

    k = Keychain.first
    assert_nil k.crypted_details
    assert_nil k.details("anykey")

    k.set_details(d, key)

    # Secrets should not leak at runtime
    assert_no_match Regexp.new(key), k.inspect
    assert_no_match Regexp.new(d[:secret]), k.inspect

    k.save!
    k.reload

    assert_equal Sentry::SymmetricSentry.encrypt_to_base64(Marshal.dump(d), key), k.crypted_details

    assert_raise(OpenSSL::CipherError) { k.details("wrongkey") }

    assert_equal d, k.details(key)

    # Secrets should not leak at runtime
    assert_no_match Regexp.new(key), k.inspect
    assert_no_match Regexp.new(d[:secret]), k.inspect
  end
end
