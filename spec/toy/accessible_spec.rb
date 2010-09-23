require 'helper'

describe Toy::Accessible do
  uses_constants('User', 'Game')

  describe 'A class with accessible attributes' do
    before do
      User.attribute :name,  String
      User.attribute :admin, Boolean, :default => false

      User.attr_accessible :name
      @user = User.create(:name => 'Steve Sloan')
    end

    it 'should have accessible attributes class method' do
      User.accessible_attributes.should == [:name].to_set
    end

    it "should default accessible attributes to empty" do
      Game.accessible_attributes.should be_empty
    end

    it "should have accessible_attributes instance method" do
      @user.accessible_attributes.should equal(User.accessible_attributes)
    end

    it "should raise error if there are protected attributes" do
      Game.attr_protected :admin
      lambda { Game.attr_accessible :name }.
        should raise_error(/Declare either attr_protected or attr_accessible for Game/)
    end

    it "should know if using accessible attributes" do
      User.accessible_attributes?.should be(true)
      Game.accessible_attributes?.should be(false)
    end

    it "should assign inaccessible attribute through accessor" do
      @user.admin = true
      @user.admin.should be_true
    end

    it "should ignore inaccessible attribute on #initialize" do
      user = User.new(:name => 'John', :admin => true)
      user.admin.should be_false
      user.name.should == 'John'
    end

    it "should not ignore inaccessible attributes on #initialize from the database" do
      user = User.new(:name => 'John')
      user.admin = true
      user.save!

      user = User.get(user.id)
      user.admin.should be_true
      user.name.should == 'John'
    end

    it "should ignore inaccessible attribute on #update_attributes" do
      @user.update_attributes(:name => 'Ren Hoek', :admin => true)
      @user.name.should == 'Ren Hoek'
      @user.admin.should be_false
    end

    it "should be indifferent to whether the accessible keys are strings or symbols" do
      @user.update_attributes("name" => 'Stimpson J. Cat', "admin" => true)
      @user.name.should == 'Stimpson J. Cat'
      @user.admin.should be_false
    end

    it "should accept nil as constructor's argument without raising exception" do
      lambda { User.new(nil) }.should_not raise_error
    end
  end
end