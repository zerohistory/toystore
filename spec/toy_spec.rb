require 'helper'

describe Toy do
  it "can encode to json" do
    Toy.encode({'foo' => 'bar'}).should == '{"foo":"bar"}'
  end

  it "can parse to json" do
    Toy.decode('{"foo":"bar"}').should == {'foo' => 'bar'}
  end
end