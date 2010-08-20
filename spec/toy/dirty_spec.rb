require 'helper'

describe Toy::Dirty do
  uses_constants('User')

  before do
    User.attribute(:name, String)
  end

  it "has no changes for new with no attributes" do
    User.new.should_not be_changed
    User.new.changed.should be_empty
    User.new.changes.should be_empty
  end

  it "has changes for new with attributes" do
    user = User.new(:name => 'Geoffrey')
    user.should be_changed
    user.changed.should include('name')
    user.changes.should == {'name' => [nil, 'Geoffrey']}
  end

  it "knows attribute changed through writer" do
    user = User.new
    user.name = 'John'
    user.should be_changed
    user.changed.should include('name')
    user.changes['name'].should == [nil, 'John']
  end

  it "knows when attribute did not change" do
    user = User.create(:name => 'Geoffrey')
    user.name = 'Geoffrey'
    user.should_not be_changed
  end

  describe "#save" do
    before      { @user = User.create(:name => 'Geoffrey') }
    let(:user)  { @user }

    it "clears changes" do
      user.name = 'John'
      user.should be_changed
      user.save
      user.should_not be_changed
    end

    it "sets previous changes" do
      user.previous_changes.should == {'name' => [nil, 'Geoffrey']}
    end
  end

  it "does not have changes when loaded from database" do
    user = User.create
    loaded = User.get(user.id)
    loaded.should_not be_changed
  end

  describe "#reload" do
    before      { @user = User.create(:name => 'John') }
    let(:user)  { @user }

    it "clears changes" do
      user.name = 'Steve'
      user.reload
      user.should_not be_changed
    end

    it "clears previously changed" do
      user.reload
      user.previous_changes.should be_empty
    end
  end

  it "has attribute changed? method" do
    user = User.new
    user.should_not be_name_changed
    user.name = 'John'
    user.should be_name_changed
  end

  it "has attribute was method" do
    user = User.create(:name => 'John')
    user.name = 'Steve'
    user.name_was.should == 'John'
  end

  it "has attribute change method" do
    user = User.create(:name => 'John')
    user.name = 'Steve'
    user.name_change.should == ['John', 'Steve']
  end

  it "has attribute will change! method" do
    user = User.create
    user.name_will_change!
    user.should be_changed
  end
end