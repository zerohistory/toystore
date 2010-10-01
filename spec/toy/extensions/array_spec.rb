require 'helper'

describe "Array.to_store" do
  it "should convert value to_a" do
    Array.to_store([1, 2, 3, 4]).should == [1, 2, 3, 4]
    Array.to_store('1').should == ['1']
    Array.to_store({'1' => '2', '3' => '4'}).should == [['1', '2'], ['3', '4']]
  end
end

describe "Array.from_store" do
  it "should be array if array" do
    Array.from_store([1, 2]).should == [1, 2]
  end

  it "should be empty array if nil" do
    Array.from_store(nil).should == []
  end
end

describe "Array.store_default" do
  it "returns emtpy array" do
    Array.store_default.should == []
  end
end