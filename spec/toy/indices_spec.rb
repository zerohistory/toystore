require 'helper'

describe Toy::Indices do
  uses_constants('User')

  it "defaults lists to empty hash" do
    User.indices.should == {}
  end

  describe "declaring a list" do
    before do
      User.attribute :ssn, String
      @index = User.index(:ssn)
    end

    it "knows about its lists" do
      User.indices[:ssn].should == Toy::Index.new(User, :ssn)
    end

    it "returns list" do
      @index.should == Toy::Index.new(User, :ssn)
    end

    it "adds indices instance method" do
      User.new.indices.should == User.indices
    end
  end

  describe ".index_key" do
    it "returns key if index exists" do
      sha = Digest::SHA1.hexdigest('taco@bell.com')
      User.attribute(:email, String)
      User.index(:email)
      User.index_key(:email, 'taco@bell.com').should == "User:email:#{sha}"
    end

    it "works with string name" do
      sha = Digest::SHA1.hexdigest('taco@bell.com')
      User.attribute(:email, String)
      User.index(:email)
      User.index_key('email', 'taco@bell.com').should == "User:email:#{sha}"
    end

    it "raises error if index does not exist" do
      lambda {
        User.index_key(:email, 'taco@bell.com')
      }.should raise_error(ArgumentError, 'Index for email does not exist')
    end
  end

  describe ".get_index (existing)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      User.create_index(:email, 'taco@bell.com', 1)
      User.create_index(:email, 'taco@bell.com', 2)
      @index = User.get_index(:email, 'taco@bell.com')
    end

    it "returns decoded array" do
      @index.should == [1, 2]
    end
  end

  describe ".get_index (missing)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      @index = User.get_index(:email, 'taco@bell.com')
    end

    it "returns empty array" do
      @index.should == []
    end
  end

  describe ".create_index (single value)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      User.create_index(:email, 'taco@bell.com', 1)
    end

    it "stores id in array" do
      User.get_index(:email, 'taco@bell.com').should == [1]
    end
  end

  describe ".create_index (multiple values)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      User.create_index(:email, 'taco@bell.com', 1)
      User.create_index(:email, 'taco@bell.com', 2)
      User.create_index(:email, 'taco@bell.com', 3)
    end

    it "stores each value in array" do
      User.get_index(:email, 'taco@bell.com').should == [1, 2, 3]
    end
  end

  describe ".create_index (same value multiple times)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      User.create_index(:email, 'taco@bell.com', 1)
      User.create_index(:email, 'taco@bell.com', 2)
      User.create_index(:email, 'taco@bell.com', 1)
    end

    it "stores value only once and doesn't change order" do
      User.get_index(:email, 'taco@bell.com').should == [1, 2]
    end
  end

  describe ".destroy_index (for missing index)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      User.destroy_index(:email, 'taco@bell.com', 1)
    end

    it "sets index to empty array" do
      User.get_index(:email, 'taco@bell.com').should == []
    end
  end

  describe ".destroy_index (for indexed id)" do
    before do
      User.attribute(:email, String)
      User.index(:email)
      User.create_index(:email, 'taco@bell.com', 1)
      User.destroy_index(:email, 'taco@bell.com', 1)
    end

    it "removes the value from the index" do
      User.get_index(:email, 'taco@bell.com').should == []
    end
  end
end