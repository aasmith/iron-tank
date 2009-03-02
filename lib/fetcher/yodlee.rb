require 'yodlee'

module Fetcher
  class Yodlee < Base
    def fetch
      cred = ::Yodlee::Credentials.new

      %w(username password expectation answers).map(&:to_sym).each do |k|
        cred.__send__("#{k}=", @details[k])
      end

      conn = ::Yodlee::Connection.new(cred)
      account = conn.accounts.detect{|a| a.id.to_s == @external_id }
      account.transactions
    end
  end
end
