require 'helper'

describe Toy do
  it "autoloads Version" do
    lambda { Toy::Version }.should_not raise_error(NameError)
  end

  it "autoloads Store" do
    lambda { Toy::Store }.should_not raise_error(NameError)
  end

  it "memoizes uuid" do
    Toy.uuid.should equal(Toy.uuid)
  end

  it "can generate next id" do
    id = Toy.next_id
    id.size.should == 36
  end
end