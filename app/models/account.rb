# An account represents a physical ledger that can send and receive payments,
# for example, checking, savings, credit card. For simpler accounts, such as 
# installment loans, use a Category instead.
class Account < Ledger
  def fetch!
    fetcher = FetcherResolver.resolve(self) # return class like UsBankFetcher
    raw_ofx = fetcher.fetch_ofx(user, self) # get the raw data
    OfxLoader.load_ofx!(user, raw_ofx) # parse and create entries
  end

  def credentials
    s = Sentry::SymmetricSentry.new
    YAML.load(s.decrypt_from_base64(encrypted_credentials))
  end

  def credentials=(credentials)
    s = Sentry::SymmetricSentry.new
    self.encrypted_credentials = s.encrypt_to_base64(credentials.to_yaml)
  end

end
