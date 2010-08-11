require 'helper'

describe Toy::Attribute do
  uses_constants('User')

  before do
    @attribute = Toy::Attribute.new(User, :age, String)
  end

  let(:attribute) { @attribute }

  it "has model" do
    attribute.model.should == User
  end

  it "has name" do
    attribute.name.should == :age
  end
  
  it "has type" do
    attribute.type.should == String
  end
  
  it "should write using the attribute type" do
    attribute.write(12).should == '12'
  end
  
  it "should write using the attribute type" do
    attribute.read(12).should == '12'
  end
end