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

  it "should read using the attribute type" do
    attribute.read(12).should == '12'
  end

  it "raises error if option is passed that we do not know about" do
    lambda {
      Toy::Attribute.new(User, :age, String, :taco => 'bell')
    }.should raise_error(ArgumentError)
  end

  it "allows :virtual option" do
    lambda {
      Toy::Attribute.new(User, :score, Integer, :virtual => true)
    }.should_not raise_error(ArgumentError)
  end

  describe "#virtual?" do
    it "defaults to false" do
      Toy::Attribute.new(User, :score, Integer).should_not be_virtual
    end

    it "returns true if :virtual => true" do
      Toy::Attribute.new(User, :score, Integer, :virtual => true).should be_virtual
    end

    it "returns false if :virtual => false" do
      Toy::Attribute.new(User, :score, Integer, :virtual => false).should_not be_virtual
    end
  end

  describe "#persisted?" do
    it "defaults to true" do
      Toy::Attribute.new(User, :score, Integer).should be_persisted
    end

    it "returns false if :virtual => true" do
      Toy::Attribute.new(User, :score, Integer, :virtual => true).should_not be_persisted
    end

    it "returns true if :virtual => false" do
      Toy::Attribute.new(User, :score, Integer, :virtual => false).should be_persisted
    end
  end

  describe "#default" do
    it "defaults to nil" do
      Toy::Attribute.new(User, :age, String).default.should be_nil
    end

    it "returns default if set" do
      Toy::Attribute.new(User, :age, String, :default => 1).default.should == 1
    end
  end

  describe "attribute with default" do
    before do
      @attribute = Toy::Attribute.new(User, :brother_name, String, :default => 'Daryl')
    end

    it "returns default when reading a nil value" do
      @attribute.read(nil).should == 'Daryl'
    end

    it "returns value when reading a non-nil value" do
      @attribute.read('Larry').should == 'Larry'
    end

    it "returns default when writing a nil value" do
      @attribute.write(nil).should == 'Daryl'
    end

    it "returns value when writing a non-nil value" do
      @attribute.write('Larry').should == 'Larry'
    end
  end

  describe "attribute with default that is proc" do
    before do
      @time = 4.days.ago
      default = proc { @time }
      @attribute = Toy::Attribute.new(User, :created_at, Time, :default => default)
    end

    it "returns default when reading a nil value" do
      @attribute.read(nil).should == @time
    end

    it "returns value when reading a non-nil value" do
      time = 3.days.ago
      @attribute.read(time).should == time
    end

    it "returns default when writing a nil value" do
      @attribute.write(nil).to_i.should == @time.to_i
    end

    it "returns value when writing a non-nil value" do
      time = 2.days.ago
      @attribute.write(time).to_i.should == time.to_i
    end
  end
end