require 'helper'

describe Toy do
  it "autoloads Version" do
    lambda { Toy::Version }.should_not raise_error(NameError)
  end

  it "autoloads Store" do
    lambda { Toy::Store }.should_not raise_error(NameError)
  end
end