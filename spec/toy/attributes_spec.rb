require 'helper'

describe Toy::Attributes do
  uses_constants('User', 'Game', 'Move', 'Tile')

  before do
    Game.embedded_list(:moves)
    Move.embedded_list(:tiles)
  end

  describe "including" do
    it "adds id attribute" do
      User.attributes.keys.should == ['id']
    end
  end

  describe ".attributes" do
    it "defaults to hash with id" do
      User.attributes.keys.should == ['id']
    end
  end

  describe "#persisted_attributes" do
    before do
      Game.embedded_list(:moves)
      @over    = Game.attribute(:over, Boolean)
      @score   = Game.attribute(:creator_score, Integer, :virtual => true)
      @abbr    = Game.attribute(:super_secret_hash, String, :abbr => :ssh)
      @rewards = Game.attribute(:rewards, Set)
      @game    = Game.new({
        :over          => true,
        :creator_score => 20,
        :rewards       => %w(twigs berries).to_set,
        :ssh           => 'h4x',
        :moves         => [Move.new, Move.new],
      })
    end

    it "includes persisted attributes" do
      @game.persisted_attributes.should have_key('over')
    end

    it "includes abbreviated names for abbreviated attributes" do
      @game.persisted_attributes.should have_key('ssh')
    end

    it "does not include full names for abbreviated attributes" do
      @game.persisted_attributes.should_not have_key('super_secret_hash')
    end

    it "includes embedded" do
      @game.persisted_attributes.should have_key('moves')
    end

    it "does not include virtual attributes" do
      @game.persisted_attributes.should_not have_key(:creator_score)
    end

    it "includes to_store values for attributes" do
      @game.persisted_attributes['rewards'].should be_instance_of(Array)
      @game.persisted_attributes['rewards'].should == @rewards.to_store(@game.rewards)
    end
  end

  describe ".defaulted_attributes" do
    before do
      @name = User.attribute(:name, String)
      @age  = User.attribute(:age, Integer, :default => 10)
    end

    it "includes attributes with a default" do
      User.defaulted_attributes.should include(@age)
    end

    it "excludes attributes without a default" do
      User.defaulted_attributes.should_not include(@name)
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

  describe "#initialize" do
    before do
      User.attribute :name, String
      User.attribute :age,  Integer
    end

    it "writes id" do
      id = User.new.id
      id.should_not be_nil
      id.size.should == 36
    end

    it "does not attempt to set id if already set" do
      user = User.new(:id => 'frank')
      user.id.should == 'frank'
    end

    it "sets attributes" do
      instance = User.new(:name => 'John', :age => 28)
      instance.name.should == 'John'
      instance.age.should  == 28
    end

    it "sets defaults" do
      User.attribute(:awesome, Boolean, :default => true)
      User.new.awesome.should be_true
    end

    it "does not fail with nil" do
      User.new(nil).should be_instance_of(User)
    end
  end

  describe "#initialize_from_database" do
    before do
      User.attribute(:age, Integer, :default => 20)
      @user = User.allocate
    end

    it "sets new record to false" do
      @user.initialize_from_database
      @user.should_not be_new_record
    end

    it "sets attributes" do
      @user.initialize_from_database('age' => 21)
    end

    it "sets defaults" do
      @user.initialize_from_database
      @user.age.should == 20
    end

    it "does not fail with nil" do
      @user.initialize_from_database(nil).should == @user
    end

    it "returns self" do
      @user.initialize_from_database.should == @user
    end
  end

  describe "#attributes" do
    it "defaults to hash with id" do
      attrs = Model().new.attributes
      attrs.keys.should == ['id']
    end

    it "includes all attributes that are not nil" do
      User.attribute(:name, String)
      User.attribute(:active, Boolean, :default => true)
      user = User.new
      user.attributes.should == {
        'id'     => user.id,
        'active' => true,
      }
    end

    it "does not include embedded documents" do
      game = Game.new(:moves => [Move.new(:tiles => [Tile.new])])
      game.attributes.should_not have_key('moves')
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

    it "works with accessors that are not keys" do
      User.class_eval { attr_accessor :foo }
      record = User.new(:foo => 'oof')
      record.foo.should == 'oof'
    end

    it "ignores keys that are not attributes and do not have accessors defined" do
      lambda { User.new(:taco => 'bell') }.should_not raise_error
    end
  end

  describe "reading an attribute" do
    before do
      User.attribute(:info, Hash)
      @user = User.new(:info => {'name' => 'John'})
    end

    it "returns the same instance" do
      @user.info.should equal(@user.info)
    end
  end

  describe "declaring an attribute" do
    before do
      User.attribute :name, String
      User.attribute :age, Integer
    end

    it "adds attribute to attributes" do
      User.attributes['name'].should == Toy::Attribute.new(User, :name, String)
      User.attributes[:name].should be_nil
      User.attributes['age'].should  == Toy::Attribute.new(User, :age, Integer)
      User.attributes[:age].should be_nil
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

  describe "declaring an attribute with a default" do
    before do
      User.attribute :active, Boolean, :default => true
    end

    it "adds attribute to attributes" do
      attribute = Toy::Attribute.new(User, :active, Boolean, {:default => true})
      User.attributes['active'].should == attribute
    end

    it "defaults value when initialized" do
      User.new.active.should be(true)
    end

    it "overrides default if present" do
      User.new(:active => false).active.should be(false)
    end
  end

  describe "declaring an attribute with an abbreviation" do
    before do
      User.attribute(:twitter_access_token, String, :abbr => 'tat')
    end

    it "aliases reading to abbreviation" do
      user = User.new
      user.twitter_access_token = '1234'
      user.tat.should == '1234'
    end

    it "aliases writing to abbreviation" do
      user = User.new
      user.tat = '1234'
      user.twitter_access_token.should == '1234'
    end

    it "persists to store using abbreviation" do
      user = User.create(:twitter_access_token => '1234')
      raw = user.store[user.store_key]
      json = Toy.decode(raw)
      json['tat'].should == '1234'
      json.should_not have_key('twitter_access_token')
    end

    it "loads from store correctly" do
      user = User.create(:twitter_access_token => '1234')
      user = User.get(user.id)
      user.twitter_access_token.should == '1234'
      user.tat.should == '1234'
    end
  end

  describe "#reload" do
    before do
      User.attribute(:name, String)
      @user = User.create(:name => 'John')
    end
    let(:user) { @user }

    it "reloads record from the database" do
      user.name = 'Steve'
      user.reload
      user.name.should == 'John'
    end

    it "is still persisted" do
      user.should be_persisted
      user.reload
      user.should be_persisted
    end

    it "returns the record" do
      user.name = 'Steve'
      user.reload.should equal(user)
    end

    it "resets instance variables" do
      user.instance_variable_set("@foo", true)
      user.reload
      user.instance_variable_get("@foo").should be_nil
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

    it "raises NotFound if does not exist" do
      user.destroy
      lambda { user.reload }.should raise_error(Toy::NotFound)
    end

    it "reloads defaults" do
      User.attribute(:skills, Array)
      @user.reload
      @user.skills.should == []
    end
  end

  describe "Initialization of array attributes" do
    before do
      User.attribute(:skills, Array)
    end

    it "initializes to empty array" do
      User.new.skills.should == []
    end
  end
end