require 'helper'

describe Toy::List do
  uses_constants('User', 'Game')

  before do
    @list = Toy::List.new(User, :games)
  end

  let(:list)  { @list }

  it "has model" do
    list.model.should == User
  end

  it "has name" do
    list.name.should == :games
  end

  it "has type" do
    list.type.should == Game
  end

  it "has key" do
    list.key.should == :game_ids
  end

  it "adds list to model" do
    User.lists.keys.should include(:games)
  end

  it "adds attribute to model" do
    User.attributes.keys.should include(:game_ids)
  end

  it "adds reader to model" do
    User.new.should respond_to(:games)
  end

  describe "#eql?" do
    it "returns true if same class, model, and name" do
      list.should eql(list)
    end

    it "returns false if not same class" do
      list.should_not eql({})
    end

    it "returns false if not same model" do
      list.should_not eql(Toy::List.new(Game, :users))
    end

    it "returns false if not the same name" do
      list.should_not eql(Toy::List.new(User, :pieces))
    end
  end
end