require 'helper'

describe Toy::Protected do
  uses_constants('User', 'Game')

  describe 'A class with protected attributes' do
    before do
      User.attribute :name, String
      User.attribute :admin, Boolean, :default => false

      User.attr_protected :admin

      @user = User.create(:name => 'Steve Sloan')
    end

    it "should have protected attributes class method" do
      User.protected_attributes.should == [:admin].to_set
    end

    it "should default protected attributes to empty" do
      Game.protected_attributes.should be_empty
    end

    it "should have protected attributes instance method" do
      @user.protected_attributes.should equal(User.protected_attributes)
    end

    it "should raise error if there are accessible attributes" do
      Game.attr_accessible :name
      lambda { Game.attr_protected :admin }.
        should raise_error(/Declare either attr_protected or attr_accessible for Game/)
    end

    it "should know if using protected attributes" do
      User.protected_attributes?.should be(true)
      Game.protected_attributes?.should be(false)
    end

    it "should assign protected attribute through accessor" do
      @user.admin = true
      @user.admin.should be_true
    end

    it "should ignore protected attribute on #initialize" do
      user = User.new(:name => 'John', :admin => true)
      user.admin.should be_false
      user.name.should == 'John'
    end

    it "should not ignore protected attributes on #initialize from the database" do
      user = User.new(:name => 'John')
      user.admin = true
      user.save!

      user = User.get(user.id)
      user.admin.should be_true
      user.name.should == 'John'
    end

    it "should ignore protected attribute on #update_attributes" do
      @user.update_attributes(:name => 'Ren Hoek', :admin => true)
      @user.name.should == 'Ren Hoek'
      @user.admin.should be_false
    end

    it "should be indifferent to whether the protected keys are strings or symbols" do
      @user.update_attributes("name" => 'Stimpson J. Cat', "admin" => true)
      @user.name.should == 'Stimpson J. Cat'
      @user.admin.should be_false
    end

    it "should accept nil as constructor's argument without raising exception" do
      lambda { User.new(nil) }.should_not raise_error
    end
  end
end