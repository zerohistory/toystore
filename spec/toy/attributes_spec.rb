require 'helper'

describe Toy::Attributes do
  describe "including" do
    it "adds id attribute" do
      Model().attributes.keys.should == [:id]
    end
  end

  describe ".attributes" do
    it "defaults to hash with id" do
      Model().attributes.keys.should == [:id]
    end
  end

  describe "initialization" do
    before do
      @model = Model do
        attribute :name, String
        attribute :age, Integer
      end
    end
    let(:model) { @model }

    it "writes id" do
      id = model.new.id
      id.should_not be_nil
      id.size.should == 36
    end

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
      @model = Model { attribute :age, Integer }
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

  describe "#attributes" do
    it "defaults to hash with id" do
      attrs = Model().new.attributes
      attrs.keys.should == ['id']
    end
  end

  describe "#attributes=" do
    it "sets attributes if present" do
      model = Model { attribute :age, Integer }.new
      model.attributes = {:age => 20}
      model.age.should == 20
    end

    it "does nothing if nil" do
      model = Model().new
      lambda { model.attributes = nil }.should_not raise_error
    end
  end

  describe "declaring an attribute" do
    before do
      @model = Model() do
        attribute :name, String
        attribute :age, Integer
      end
    end
    let(:model) { @model }

    it "adds attribute to attributes" do
      model.attributes.should include(:age)
      model.attributes.should include(:name)
    end

    it "adds accessors" do
      record = model.new
      record.name = 'John'
      record.name.should == 'John'
    end

    it "converts to attribute type" do
      record = model.new
      record.age = '12'
      record.age.should == 12
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

    it "aliases [] to read_attribute" do
      record = model.new(:name => 'John')
      record[:name].should == 'John'
    end

    it "aliases []= to write_attribute" do
      record = model.new
      record[:name] = 'John'
      record.name.should == 'John'
    end
  end
end