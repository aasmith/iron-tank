# == Schema Information
# Schema version: 20090227093920
#
# Table name: ledgers
#
#  id          :integer         not null, primary key
#  type        :string(255)
#  name        :string(255)
#  user_id     :integer
#  keychain_id :integer
#  external_id :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

# An account represents a physical ledger that can send and receive payments,
# for example, checking, savings, credit card. For simpler accounts, such as 
# installment loans, use a Category instead.
class Account < Ledger
  serialize :credentials
  before_save :encrypt

  def after_find; decrypt_or_initialize; end
  def after_save; decrypt_or_initialize; end

  def after_initialize
    if new_record?
      self.credentials = Hash.new
    end
  end

  def fetch!
    fetcher_class = Fetcher.resolve(:institution => institution)
    fetcher = fetcher_class.new(self)
    OfxLoader.load_ofx!(user, fetcher.fetch_ofx) # parse and create entries
  end

  def encrypt
    s = Sentry::SymmetricSentry.new
    self.credentials = s.encrypt_to_base64(credentials.to_yaml)
  end

  def decrypt_or_initialize
    s = Sentry::SymmetricSentry.new

    write_attribute("credentials", (credentials ?
      YAML.load(s.decrypt_from_base64(
        read_attribute_before_type_cast("credentials"))) : Hash.new ))
  end

end
