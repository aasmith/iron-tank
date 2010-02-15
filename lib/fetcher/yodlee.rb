require 'yodlee'

module Fetcher
  class Yodlee < Base
    def fetch
      account = connection.accounts.detect{|a| a.id.to_s == @external_id } or 
                  raise "Account ext:#{@external_id} was not found"

      account.transactions
    end

    def list
      connection.accounts
    end

    private

    def connection
      cred = ::Yodlee::Credentials.new

      %w(username password expectation answers).map(&:to_sym).each do |k|
        cred.__send__("#{k}=", @details[k])
      end

      ::Yodlee::Connection.new(cred)
    end
  end
end
