require 'helper'

describe Toy do
  it "autoloads Version" do
    lambda { Toy::Version }.should_not raise_error(NameError)
  end

  it "autoloads Store" do
    lambda { Toy::Store }.should_not raise_error(NameError)
  end

  it "can encode to json" do
    Toy.encode({'foo' => 'bar'}).should == '{"foo":"bar"}'
  end

  it "can parse to json" do
    Toy.decode('{"foo":"bar"}').should == {'foo' => 'bar'}
  end
end