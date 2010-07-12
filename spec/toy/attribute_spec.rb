require 'helper'

describe Toy::Attribute do
  let(:model)     { Model() }
  let(:attr_name) { :age }
  let(:attr_type) { String }
  let(:attribute) { Toy::Attribute.new(model, attr_name, attr_type) }

  it "has model" do
    attribute.model.should == model
  end

  it "has name" do
    attribute.name.should == attr_name
  end
  
  it "has type" do
    attribute.type.should == attr_type
  end
  
  it "should write using the attribute type" do
    attribute.write(12).should == '12'
  end
  
  it "should write using the attribute type" do
    attribute.read(12).should == '12'
  end
end