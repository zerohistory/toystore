require 'helper'

describe "String.to_store" do
  it "should convert value to_s" do
    [21, '21'].each do |value|
      String.to_store(value).should == '21'
    end
  end

  it "should be nil if nil" do
    String.to_store(nil).should be_nil
  end
end

describe "String.from_store" do
  it "should be string if value present" do
    String.from_store('Scotch! Scotch! Scotch!').should == 'Scotch! Scotch! Scotch!'
  end

  it "should return nil if nil" do
    String.from_store(nil).should be_nil
  end

  it "should return empty string if blank" do
    String.from_store('').should == ''
  end
end

