require 'mechanize'

module Fetcher
  class UsBank < Base
    USBANK_TZ = "America/Chicago"

    #TODO: This class is broken.
    #self.institution = "US Bank"
    #self.fid = "1402"

    #def initialize(account)
    #  @account = account

    #  # TODO: check if account credentials are 'unlocked'?
    #  # TODO: check if needed attributes are present: account number, 
    #  # username, password, etc.
    #end

    #def fetch_ofx
    #  a = WWW::Mechanize.new

    #  p = a.get('https://www4.usbank.com/internetBanking/RequestRouter?requestCmdId=DisplayLoginPage')
    #  f = p.form_with(:name => 'logon')
    #  f.USERID = @account.credentials[:username]
    #  p = f.submit

    #  f = p.form_with(:name=>'password')
    #  f.PSWD = @account.credentials[:password]
    #  p = f.submit

    #  p = p.links.text("Download Transaction Data").click

    #  f = p.form_with(:name => 'download')
    #  accts = f.field('TDACCOUNTLIST')
    #  accts.options.detect{|o|
    #    o.text =~ /#{@account.account_number.to_s.last(4)}\s/
    #  }.click

    #    fmt = f.field('TDSOFTWARE')
    #    fmt.options.detect{|o|o.text =~ /Microsoft Money 98 or newer/}.click

    #    Time.use_zone(USBANK_TZ) do
    #      f.field('TDENDDATE').value = Time.zone.now.strftime("%Y%m%d")
    #      f.field('TDLASTDOWNLOADDATE').value = 89.days.ago.strftime("%Y%m%d")
    #    end

    #    file = f.submit
    #    file.body
    #end
  end
end
