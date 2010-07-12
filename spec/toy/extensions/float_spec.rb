require 'helper'

describe "Float.to_store" do
  it "should convert value to_f" do
    [21, 21.0, '21'].each do |value|
      Float.to_store(value).should == 21.0
    end
  end

  it "should leave nil values nil" do
    Float.to_store(nil).should == nil
  end
end

