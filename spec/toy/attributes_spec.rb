require 'helper'

describe Toy::Attributes do
  describe "including" do
    it "adds #attributes defaulting to empty hash" do
      Model().new.attributes.should == {}
    end
  end

  describe "initialization" do
    before do
      @model = Model do
        attribute :name
        attribute :age
      end
    end
    let(:model) { @model }

    it "sets attributes" do
      instance = model.new(:name => 'John', :age => 28)
      instance.name.should == 'John'
      instance.age.should  == 28
    end

    it "does not fail with nil" do
      model.new(nil).should be_instance_of(model)
    end
  end

  describe ".attribute?" do
    before do
      @model = Model { attribute :age }
    end
    let(:model) { @model }

    it "returns true if attribute (symbol)" do
      model.attribute?(:age).should be_true
    end

    it "returns true if attribute (string)" do
      model.attribute?('age').should be_true
    end
    
    it "returns false if not attribute" do
      model.attribute?(:foobar).should be_false
    end
  end

  describe "declaring an attribute" do
    before do
      @model = Model() do
        attribute :name
        attribute :age
      end
    end
    let(:model) { @model }

    it "adds attribute to attributes" do
      model.model_attributes.size.should == 2
      model.model_attributes.keys.should == [:age, :name]
      model.model_attributes[:name].should be_instance_of(Toy::Attribute)
      model.model_attributes[:age].should be_instance_of(Toy::Attribute)
    end

    it "adds accessors" do
      record = model.new
      record.name = 'John'
      record.name.should == 'John'
    end

    it "adds query-ers" do
      record = model.new
      record.name?.should be_false
      record.name = 'John'
      record.name?.should be_true
    end

    it "knows if it responds to attribute method" do
      record = model.new
      record.respond_to?(:name)
      record.respond_to?(:name=)
      record.respond_to?(:name?)
    end
  end
end