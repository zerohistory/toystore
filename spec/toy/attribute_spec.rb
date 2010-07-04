require 'helper'

describe Toy::Attribute do
  let(:model)     { Model() }
  let(:attr_name) { :age }
  let(:attribute) { Toy::Attribute.new(model, attr_name) }

  it "has model" do
    attribute.model.should == model
  end

  it "has name" do
    attribute.name.should == attr_name
  end
end