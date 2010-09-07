require 'helper'

describe Toy::Reference do
  uses_constants('User', 'Game', 'Move')

  before do
    @reference = Game.reference(:user)
  end

  let(:reference)  { @reference }

  it "has model" do
    reference.model.should == Game
  end

  it "has name" do
    reference.name.should == :user
  end

  it "has type" do
    reference.type.should == User
  end

  it "has key" do
    reference.key.should == :user_id
  end

  it "has instance_variable" do
    reference.instance_variable.should == :@_user
  end

  it "adds reference to model" do
    Game.references.keys.should include(:user)
  end

  it "adds attribute to model" do
    Game.attributes.keys.should include(:user_id)
  end

  it "adds reader method" do
    Game.new.should respond_to(:user)
  end

  it "adds writer method" do
    Game.new.should respond_to(:user=)
  end

  describe "#eql?" do
    it "returns true if same class, model, and name" do
      reference.should eql(reference)
    end

    it "returns false if not same class" do
      reference.should_not eql({})
    end

    it "returns false if not same model" do
      reference.should_not eql(Toy::Reference.new(Move, :user))
    end

    it "returns false if not the same name" do
      reference.should_not eql(Toy::Reference.new(Game, :move))
    end
  end

  describe "setting reference type" do
    before do
      @reference = Game.reference(:creator, User)
    end
    let(:reference) { @reference }

    it "uses type provided instead of inferring from name" do
      reference.type.should be(User)
    end

    it "works properly when reading and writing" do
      user = User.create
      game = Game.create
      game.creator = user
      game.creator.should == user
    end
  end

  describe "reference reader" do
    before do
      @user = User.create
      @game = Game.create(:user_id => @user.id)
    end

    it "returns instance" do
      @game.user.should == @user
    end

    it "memoizes result" do
      @game.user.should == @user
      User.should_not_receive(:get)
      @game.user.should == @user
    end

    it "does not query if id attribute is blank" do
      game = Game.create
      User.should_not_receive(:get)
      game.user
    end
  end

  describe "reference writer" do
    before do
      @user1 = User.create
      @user2 = User.create
      @game  = Game.create
      @game.user = @user1
    end

    it "sets the attribute" do
      @game.user_id.should == @user1.id
    end

    it "unmemoizes the reader" do
      @game.user.should == @user1
      @game.user = @user2
      @game.user.should == @user2
    end

    it "raises error if wrong type assigned" do
      lambda {
        @game.user = Move.new
      }.should raise_error(ArgumentError, "User expected, but was Move")
    end

    describe "with nil value" do
      before do
        @game.user = nil
      end

      it "returns nil for reader" do
        @game.user.should be_nil
      end

      it "returns nil for attribute" do
        @game.user_id.should be_nil
      end
    end
  end

  describe "reference boolean" do
    before do
      @user = User.create
      @game = Game.create
    end

    it "returns false if not set" do
      @game.user?.should be_false
    end

    it "returns true if set" do
      @game.user = @user
      @game.user?.should be_true
    end
  end

  describe "reference#nil?" do
    before do
      @user = User.create
      @game = Game.create
    end

    it "returns true if nil" do
      @game.user.should be_nil
    end

    it "returns false if not nil" do
      @game.user = @user
      @game.user.should_not be_nil
    end
  end

  describe "reference#blank?" do
    before do
      @user = User.create
      @game = Game.create
    end

    it "returns true if nil" do
      @game.user.should be_blank
    end

    it "returns false if not nil" do
      @game.user = @user
      @game.user.should_not be_blank
    end
  end

  describe "reference#present?" do
    before do
      @user = User.create
      @game = Game.create
    end

    it "returns true if present" do
      @game.user = @user
      @game.user.should be_present
    end

    it "returns false if not present" do
      @game.user.should_not be_present
    end
  end

  describe "reference#reset" do
    before do
      @user = User.create
      @game  = Game.create
      @game.user = @user
    end

    it "unmemoizes the list" do
      @game.user.should == @user
      @game.user.reset
      User.should_receive(:get).and_return(@user)
      @game.user.should == @user
    end

    it "should be reset when owner is reloaded" do
      @game.reload
      User.should_receive(:get).and_return(@user)
      @game.user.should == @user
    end
  end

  describe "reference#inspect" do
    before do
      @user = User.create
      @game = Game.create
    end

    it "returns nil if nil" do
      @game.user.inspect.should == 'nil'
    end

    it "delegates to target if present" do
      @game.user = @user
      @game.user.inspect.should == %Q(#<User:#{@user.object_id} id: "#{@user.id}">)
    end
  end

  shared_examples_for 'reference#create' do
    it "returns instance" do
      @user.should be_instance_of(User)
    end

    it "creates instance" do
      @user.should be_persisted
    end

    it "sets id attribute" do
      @game.user_id.should == @user.id
    end
  end

  describe "reference#create" do
    before do
      @game = Game.create
      @user = @game.user.create
    end

    it_should_behave_like 'reference#create'
  end

  describe "reference#create (with attributes)" do
    before do
      User.attribute(:name, String)
      @game = Game.create
      @user = @game.user.create(:name => 'John')
    end

    it_should_behave_like 'reference#create'

    it "sets attributes" do
      @user.name.should == 'John'
    end
  end

  shared_examples_for 'reference#build' do
    it "returns instance" do
      @user.should be_instance_of(User)
    end

    it "builds instance" do
      @user.should_not be_persisted
    end

    it "sets id attribute" do
      @game.user_id.should == @user.id
    end

    it "does not save owner" do
      @game.should_not_receive(:save)
      @game.user.build
    end
  end

  describe "reference#build" do
    before do
      @game = Game.create
      @user = @game.user.build
    end

    it_should_behave_like 'reference#build'
  end

  describe "reference#build (with attributes)" do
    before do
      User.attribute(:name, String)
      @game = Game.create
      @user = @game.user.build(:name => 'John')
    end

    it_should_behave_like 'reference#build'

    it "sets attributes" do
      @user.name.should == 'John'
    end
  end
end