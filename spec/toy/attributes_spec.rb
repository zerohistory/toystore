require 'helper'

describe Toy::Attributes do
  describe "declaring an attribute" do
    before do
      @model = Model() do
        attribute :name
        attribute :age
      end
    end
    let(:model) { @model }

    it "adds attribute to attributes" do
      model.attributes.size.should == 2
      model.attributes.keys.should == [:age, :name]
      model.attributes[:name].should be_instance_of(Toy::Attribute)
      model.attributes[:age].should be_instance_of(Toy::Attribute)
    end

    it "adds accessors" do
      record = model.new
      record.name = 'John'
      record.name.should == 'John'
    end
  end
end