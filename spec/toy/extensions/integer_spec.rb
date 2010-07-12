require 'helper'

describe "Integer.to_store" do
  it "should convert value to integer" do
    [21, 21.0, '21'].each do |value|
      Integer.to_store(value).should == 21
    end
  end

  it "should work fine with big integers" do
    [9223372036854775807, '9223372036854775807'].each do |value|
      Integer.to_store(value).should == 9223372036854775807
    end
  end
end

