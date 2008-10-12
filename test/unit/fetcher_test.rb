require 'test_helper'

Foo = Class.new(Fetcher) { self.institution = "Foo Bank" } 
Bar = Class.new(Fetcher) { self.institution = "Bar Bank" } 

class FetcherTest < ActiveSupport::TestCase
  test "resolves correct fetcher" do
    assert_equal Bar, Fetcher.resolve(:institution => "Bar Bank")
  end

  test "resolves no fetcher" do
    assert_nil Fetcher.resolve(:institution => "Qux Bank")
  end

  test "no error when resolving nonexistant property" do
    assert_nothing_raised { Fetcher.resolve(:nothing => 123) }
  end
end
