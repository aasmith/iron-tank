require 'test_helper'
require 'flexmock/test_unit'

class AccountTest < ActiveSupport::TestCase
  test "fetch" do
    adapter = flexmock Adapter.new
    fetcher = flexmock "fetcher"
    converter = flexmock "converter"

    a = Account.find_by_name "Checking"
    a.adapter = adapter

    details = {:username => "foo", :password => "bar"}

    adapter.
      should_receive("fetcher_class.new").once.
      with(details, a.external_id).
      and_return(fetcher).
      globally.ordered

    fetcher.
      should_receive("fetch").once.
      and_return([:raw]).
      globally.ordered

    adapter.
      should_receive("converter_class").once.
      and_return(converter).
      globally.ordered

    converter.should_receive("convert").once.
      with([:raw]).
      and_return([]).
      globally.ordered

    flexmock(Loader).
      new_instances.
      should_receive("load!").once.
      with([]).
      globally.ordered

    a.fetch!(details)
  end
end
