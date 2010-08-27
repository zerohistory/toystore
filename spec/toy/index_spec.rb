require 'helper'

describe Toy::Index do
  uses_constants('User', 'Student')

  before do
    User.attribute(:ssn, String)
    @index = User.index(:ssn)
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

  it "has a key for a value" do
    index.key('some_value').should == 'User:ssn:some_value'
  end

  it "adds index to model" do
    User.indices.keys.should include(:ssn)
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

  describe "creating with index" do
    before do
      @user = User.create(:ssn => '555-00-1234')
    end
    let(:user) { @user }

    it "creates key for indexed value" do
      User.store.key?("User:ssn:555-00-1234").should be_true
    end

    it "adds instance id to index array" do
      User.get_index(:ssn, '555-00-1234').should == [user.id]
    end
  end

  describe "creating second record for same index value" do
    before do
      @user1 = User.create(:ssn => '555-00-1234')
      @user2 = User.create(:ssn => '555-00-1234')
    end

    it "adds both instances to index" do
      User.get_index(:ssn, '555-00-1234').should == [@user1.id, @user2.id]
    end
  end

  describe "destroying with index" do
    before do
      @user = User.create(:ssn => '555-00-1234')
      @user.destroy
    end

    it "removes id from index" do
      User.get_index(:ssn, '555-00-1234').should == []
    end
  end

  describe "updating record and changing indexed value" do
    before do
      @user = User.create(:ssn => '555-00-1234')
      @user.update_attributes(:ssn => '555-00-4321')
    end

    it "removes from old index" do
      User.get_index(:ssn, '555-00-1234').should == []
    end

    it "adds to new index" do
      User.get_index(:ssn, '555-00-4321').should == [@user.id]
    end
  end

  describe "updating record without changing indexed value" do
    before do
      @user = User.create(:ssn => '555-00-1234')
      @user.update_attributes(:ssn => '555-00-1234')
    end

    it "leaves index alone" do
      User.get_index(:ssn, '555-00-1234').should == [@user.id]
    end
  end

  describe "first by index" do
    it "should not find values that are not in index" do
      User.first_by_ssn('does-not-exist').should be_nil
    end

    it "should find indexed value" do
      user = User.create(:ssn => '555-00-1234')
      User.first_by_ssn('555-00-1234').should == user
    end
  end

  describe "first or new by index" do
    it "initializes if not existing" do
      user = User.first_or_new_by_ssn('does-not-exist')
      user.ssn.should == 'does-not-exist'
      user.should_not be_persisted
    end

    it "returns if existing" do
      user = User.create(:ssn => '555-00-1234')
      User.first_or_new_by_ssn('555-00-1234').should == user
    end
  end

  describe "first or create by index" do
    it "creates if not existing" do
      user = User.first_or_create_by_ssn('does-not-exist')
      user.ssn.should == 'does-not-exist'
      user.should be_persisted
    end

    it "returns if existing" do
      user = User.create(:ssn => '555-00-1234')
      User.first_or_create_by_ssn('555-00-1234').should == user
    end
  end
end