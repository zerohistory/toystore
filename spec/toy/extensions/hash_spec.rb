require 'helper'

describe "Hash.from_store" do
  it "should convert hash to hash with indifferent access" do
    hash = Hash.from_store(:foo => 'bar')
    hash[:foo].should  == 'bar'
    hash['foo'].should == 'bar'
  end

  it "should be hash if nil" do
    hash = Hash.from_store(nil)
    hash.should == {}
    hash.is_a?(HashWithIndifferentAccess).should be_true
  end
end

describe "Hash.store_default" do
  it "returns emtpy hash with indifferent access" do
    Hash.store_default.should == {}.with_indifferent_access
  end
end