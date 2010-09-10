require 'helper'

describe Toy::References do
  uses_constants('User', 'Game')

  it "defaults references to empty hash" do
    User.references.should == {}
  end

  describe ".reference?" do
    before do
      Game.reference(:user)
    end

    it "returns true if attribute (symbol)" do
      Game.reference?(:user).should be_true
    end

    it "returns true if attribute (string)" do
      Game.reference?('user').should be_true
    end

    it "returns false if not attribute" do
      Game.reference?(:foobar).should be_false
    end
  end

  describe "declaring a reference" do
    before do
      @reference = Game.reference(:user)
    end

    it "knows about its references" do
      Game.references[:user].should == Toy::Reference.new(Game, :user)
    end

    it "returns reference" do
      @reference.should == Toy::Reference.new(Game, :user)
    end
  end

  describe "declaring a reference with options" do
    before do
      @reference = Game.reference(:user, :some_option => true)
    end
    let(:reference) { @reference }

    it "sets type" do
      reference.type.should be(User)
    end

    it "sets options" do
      reference.options.should == {:some_option => true}
    end
  end

  describe "declaring a reference with type" do
    before do
      @reference = Game.reference(:creator, User)
    end
    let(:reference) { @reference }

    it "sets type" do
      reference.type.should be(User)
    end

    it "sets options" do
      reference.options.should == {}
    end
  end

  describe "declaring a reference with type and options" do
    before do
      @reference = Game.reference(:creator, User, :some_option => true)
    end
    let(:reference) { @reference }

    it "sets type" do
      reference.type.should be(User)
    end

    it "sets options" do
      reference.options.should == {:some_option => true}
    end
  end
end