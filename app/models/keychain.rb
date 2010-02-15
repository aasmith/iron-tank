# == Schema Information
# Schema version: 20091019043039
#
# Table name: keychains
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  crypted_details :text
#  created_at      :datetime
#  updated_at      :datetime
#  description     :string(255)
#

# A keychain is a collection of credentials that can be used to access
# transactions stored at a remote institution and can be associated with 
# one or more local Account instances.
# 
# == Adding a new keychain
# 
# When a user adds a new keychain, they are prompted for the key to use.
# This key should be tested against one of their other keychains (if any).
# If the other keychain does not decrypt, then the key is rejected. This
# forces the user to use the same key for all keychains, this behaving
# like a 'vault' password, without ever needing to store it to the database.
# 
# == Using a keychain
# 
# User is prompted for the keychain password. This is stored in memory
# and used as the key when accessing Keychain#details(key)
# 
# Keychain has details/crypted_details. Encrypted with a symmetric cipher
# and the user's keychain password. Now the keychain password is available,
# the details can be decrypted and used for fetching bank transactions.
#
class Keychain < ActiveRecord::Base
  has_many :ledgers
  belongs_to :user

  def set_details(details, key)
    raise "No key supplied" unless key

    enc = Huberry::Encryptor.encrypt(:value => Marshal.dump(details), :key => key)

    self.crypted_details = Base64.encode64(enc)
  end

  def details(key)
    raise "No key supplied" unless key
    return nil unless crypted_details

    enc = Base64.decode64(crypted_details)

    Marshal.load(Huberry::Encryptor.decrypt(:value => enc, :key => key))
  end

end
