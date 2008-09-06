require 'test_helper'

class MappingTest < ActiveSupport::TestCase
  test "match equal" do
    mapping = Mapping.first(:conditions => {:condition => Mapping::EQUALS})
    assert_equal [mapping], Mapping.all.select{|m| m.match?(mapping.value)}
  end

  test "match begin" do
    mapping = Mapping.first(:conditions => {:condition => Mapping::BEGINS})
    assert_equal [mapping], Mapping.all.select{|m| 
      m.match?(mapping.value.first(4))}
  end

  test "match contains" do
    mapping = Mapping.first(:conditions => {:condition => Mapping::CONTAINS})
    assert_equal [mapping], Mapping.all.select{|m| m.match?(mapping.value[2,3])}
  end

  test "match doesnt find anything for empty strings" do
    assert_equal [], Mapping.all.select{|m|m.match?("")}
    assert_equal [], Mapping.all.select{|m|m.match?(nil)}
  end
end
