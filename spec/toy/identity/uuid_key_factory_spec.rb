require 'helper'

describe Toy::Identity::UUIDKeyFactory do
  it "should use uuid for next key" do
    Toy::Identity::UUIDKeyFactory.new.next_key(nil).length.should == 36
  end
end