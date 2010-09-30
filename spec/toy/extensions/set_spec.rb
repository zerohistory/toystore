require 'helper'

describe "Set.to_store" do
  it "should convert value to_a" do
    Set.to_store(Set.new([1,2,3])).should == [1,2,3]
  end

  it "should convert to empty array if nil" do
    Set.to_store(nil).should == []
  end
end

describe "Set.from_store" do
  it "should be a set if array" do
    Set.from_store([1,2,3]).should == Set.new([1,2,3])
  end

  it "should be empty set if nil" do
    Set.from_store(nil).should == Set.new([])
  end
end

describe "Set.store_default" do
  it "returns empty set" do
    Set.store_default.should == Set.new
  end
end