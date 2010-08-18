require 'helper'

describe Toy::Index do
  uses_constants('User', 'Student')

  before do
    User.attribute :ssn, String
    @index = User.index :ssn
  end

  let(:index) { @index }

  it "has a model" do
    index.model.should == User
  end

  it "has a name" do
    index.name.should == :ssn
  end

  it "raises error if attribute does not exist" do
    lambda {
      User.index :student_id
    }.should raise_error(ArgumentError, "No attribute student_id for index")
  end

  it "has a store key for a value" do
    index.store_key('some_value').should == 'User:ssn:some_value'
  end

  it "adds index to model" do
    User.indices.keys.should include(:ssn)
  end

  it "adds finder to model" do
    User.should respond_to(:find_by_ssn)
  end

  it "adds index writer" do
    User.new.should respond_to(:add_to_ssn_index)
  end

  it "adds index remover" do
    User.new.should respond_to(:remove_from_ssn_index)
  end

  describe "#eql?" do
    it "returns true if same class, model, and name" do
      index.should eql(index)
    end

    it "returns false if not same class" do
      index.should_not eql({})
    end

    it "returns false if not same model" do
      Student.attribute :ssn, String
      index.should_not eql(Toy::Index.new(Student, :ssn))
    end

    it "returns false if not the same name" do
      User.attribute :student_id, String
      index.should_not eql(Toy::Index.new(User, :student_id))
    end
  end

  describe "writing and removing to index" do
    it "should write the id to the store" do
      user = User.create(:ssn => '555-00-1234')
      User.store[index.store_key(user.ssn)].should == user.id
    end

    it "should write the id to the store" do
      user = User.create(:ssn => '555-00-1234')
      User.store[index.store_key(user.ssn)].should == user.id

      user.destroy
      User.store[index.store_key(user.ssn)].should be_nil
    end
  end

  describe "finding by index" do
    it "should not find values that are not in index" do
      User.find_by_ssn('does-not-exist').should be_nil
    end

    it "should find indexed value" do
      user = User.create(:ssn => '555-00-1234')

      User.find_by_ssn('555-00-1234').should == user
    end
  end
  
  describe "finding or creating by index" do
    it "should not find values that are not in index" do
      User.find_by_ssn('does-not-exist').should be_nil

      user = User.find_or_create_by_ssn('does-not-exist')
      user.ssn.should == 'does-not-exist'
      
      User.find_by_ssn('does-not-exist').should_not be_nil
    end

    it "should find indexed value" do
      user = User.create(:ssn => '555-00-1234')

      User.find_or_create_by_ssn('555-00-1234').should == user
    end
  end
  
end