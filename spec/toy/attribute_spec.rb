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

  it "can convert from_store using the attribute type" do
    attribute.from_store(12).should == '12'
  end

  it "can convert to_store using the attribute type" do
    attribute.to_store(12).should == '12'
  end

  it "raises error if option is passed that we do not know about" do
    lambda {
      Toy::Attribute.new(User, :age, String, :taco => 'bell')
    }.should raise_error(ArgumentError)
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

    it "returns store_default if set for type" do
      Toy::Attribute.new(User, :skills, Array).default.should == []
    end

    it "returns default if set even if store_default is set" do
      Toy::Attribute.new(User, :skills, Array, :default => [1]).default.should == [1]
    end
  end

  describe "#default?" do
    it "returns false if no default or store_default" do
      Toy::Attribute.new(User, :age, String).default?.should be_false
    end

    it "returns true if default set" do
      Toy::Attribute.new(User, :age, String, :default => 1).default?.should be_true
    end

    it "returns true if store_default set" do
      Toy::Attribute.new(User, :skills, Array).default?.should be_true
    end
  end

  describe "#store_key" do
    it "returns abbr if abbreviated" do
      Toy::Attribute.new(User, :age, String, :abbr => :a).store_key.should == 'a'
    end

    it "returns name if not abbreviated" do
      Toy::Attribute.new(User, :age, String).store_key.should == 'age'
    end
  end

  describe "attribute with default" do
    before do
      @attribute = Toy::Attribute.new(User, :brother_name, String, :default => 'Daryl')
    end

    it "returns default when reading a nil value" do
      @attribute.from_store(nil).should == 'Daryl'
    end

    it "returns value when reading a non-nil value" do
      @attribute.from_store('Larry').should == 'Larry'
    end

    it "returns default when writing a nil value" do
      @attribute.to_store(nil).should == 'Daryl'
    end

    it "returns value when writing a non-nil value" do
      @attribute.to_store('Larry').should == 'Larry'
    end
  end

  describe "attribute with default that is proc" do
    before do
      default = proc { 'foo' }
      @attribute = Toy::Attribute.new(User, :foo, String, :default => default)
    end

    it "returns default when reading a nil value" do
      @attribute.from_store(nil).should == 'foo'
    end

    it "returns value when reading a non-nil value" do
      @attribute.from_store('bar').should == 'bar'
    end

    it "returns default when writing a nil value" do
      @attribute.to_store(nil).should == 'foo'
    end

    it "returns value when writing a non-nil value" do
      @attribute.to_store('bar').should == 'bar'
    end
  end

  describe "#abbr" do
    it "returns abbr if present" do
      Toy::Attribute.new(User, :twitter_access_token, String, :abbr => :tat).abbr.should == :tat
    end

    it "returns abbr as symbol if present as string" do
      Toy::Attribute.new(User, :twitter_access_token, String, :abbr => 'tat').abbr.should == :tat
    end

    it "returns nil if not present" do
      Toy::Attribute.new(User, :twitter_access_token, String).abbr.should be_nil
    end
  end

  describe "#abbr?" do
    it "returns true if abbreviation present" do
      Toy::Attribute.new(User, :twitter_access_token, String, :abbr => :tat).abbr?.should be_true
    end

    it "returns false if abbreviation missing" do
      Toy::Attribute.new(User, :twitter_access_token, String).abbr?.should be_false
    end
  end
end