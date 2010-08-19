require 'helper'

describe Toy::Querying do
  uses_constants('User', 'Game')

  before do
    User.attribute :name, String
  end

  describe ".[]" do
    it "is aliased to get" do
      john = User.create(:name => 'John')
      User[john.id].name.should == 'John'
    end

    it "returns nil if not found" do
      User['1'].should be_nil
    end
  end

  describe ".get" do
    it "returns document if found" do
      john = User.create(:name => 'John')
      User.get(john.id).name.should == 'John'
    end

    it "returns nil if not found" do
      User.get('1').should be_nil
    end
  end

  describe ".get!" do
    it "returns document if found" do
      john = User.create(:name => 'John')
      User.get!(john.id).name.should == 'John'
    end

    it "raises not found exception if not found" do
      lambda {
        User.get!('1')
      }.should raise_error(Toy::NotFound, 'Could not find document with id: "1"')
    end
  end

  describe ".get_multi" do
    it "returns array of documents" do
      john  = User.create(:name => 'John')
      steve = User.create(:name => 'Steve')
      User.get_multi(john.id, steve.id).should == [john, steve]
    end
  end

  describe ".key?" do
    it "returns true if key exists" do
      doc = User.create(:name => 'John')
      User.key?(doc.id).should be_true
    end

    it "returns false if key does not exist" do
      User.key?('taco:bell:tacos').should be_false
    end
  end

  describe ".has_key?" do
    it "returns true if key exists" do
      doc = User.create(:name => 'John')
      User.has_key?(doc.id).should be_true
    end

    it "returns false if key does not exist" do
      User.has_key?('taco:bell:tacos').should be_false
    end
  end

  describe ".load" do
    before    { @doc = User.create(:name => 'John') }
    let(:doc) { @doc }

    it "marks object as persisted" do
      doc.should be_persisted
    end

    it "decodes the object" do
      User[doc.id].name.should == 'John'
    end
  end

  describe "#reload" do
    before        { @user = User.create(:name => 'John') }
    let(:user)  { @user }

    it "reloads record from the database" do
      user.name = 'Steve'
      user.reload
      user.name.should == 'John'
    end

    it "returns the record" do
      user.name = 'Steve'
      user.reload.should equal(user)
    end

    it "resets lists" do
      User.list(:games)
      game = Game.create
      user.update_attributes(:games => [game])
      user.games = []
      user.games.should == []
      user.reload
      user.games.should == [game]
    end

    it "resets references" do
      Game.reference(:user)
      game = Game.create(:user => user)
      game.user = nil
      game.user.should be_nil
      game.reload
      game.user.should == user
    end
  end
end