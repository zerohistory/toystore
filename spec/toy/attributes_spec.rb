require 'helper'

describe Toy::Attributes do
  uses_constants('User')

  describe "including" do
    it "adds id attribute" do
      User.attributes.keys.should == [:id]
    end
  end

  describe ".attributes" do
    it "defaults to hash with id" do
      User.attributes.keys.should == [:id]
    end
  end

  describe "initialization" do
    before do
      User.attribute :name, String
      User.attribute :age,  Integer
    end

    it "writes id" do
      id = User.new.id
      id.should_not be_nil
      id.size.should == 36
    end

    it "sets attributes" do
      instance = User.new(:name => 'John', :age => 28)
      instance.name.should == 'John'
      instance.age.should  == 28
    end

    it "does not fail with nil" do
      User.new(nil).should be_instance_of(User)
    end
  end

  describe ".attribute?" do
    before do
      User.attribute :age, Integer
    end

    it "returns true if attribute (symbol)" do
      User.attribute?(:age).should be_true
    end

    it "returns true if attribute (string)" do
      User.attribute?('age').should be_true
    end

    it "returns false if not attribute" do
      User.attribute?(:foobar).should be_false
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
      User.attribute :age, Integer
      record = User.new
      record.attributes = {:age => 20}
      record.age.should == 20
    end

    it "does nothing if nil" do
      record = User.new
      lambda { record.attributes = nil }.should_not raise_error
    end
  end

  describe "declaring an attribute" do
    before do
      User.attribute :name, String
      User.attribute :age, Integer
    end

    it "adds attribute to attributes" do
      User.attributes[:name].should == Toy::Attribute.new(User, :name, String)
      User.attributes[:age].should  == Toy::Attribute.new(User, :age, Integer)
    end

    it "adds accessors" do
      record = User.new
      record.name = 'John'
      record.name.should == 'John'
    end

    it "converts to attribute type" do
      record = User.new
      record.age = '12'
      record.age.should == 12
    end

    it "adds query-ers" do
      record = User.new
      record.name?.should be_false
      record.name = 'John'
      record.name?.should be_true
    end

    it "knows if it responds to attribute method" do
      record = User.new
      record.should respond_to(:name)
      record.should respond_to(:name=)
      record.should respond_to(:name?)
    end

    it "know if it does not respond to method" do
      record = User.new
      record.should_not respond_to(:foobar)
    end

    it "aliases [] to read_attribute" do
      record = User.new(:name => 'John')
      record[:name].should == 'John'
    end

    it "aliases []= to write_attribute" do
      record = User.new
      record[:name] = 'John'
      record.name.should == 'John'
    end
  end
end