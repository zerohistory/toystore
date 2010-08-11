require 'helper'

describe Toy::List do
  before  { create_constant('Game') }
  after   { remove_constant('Game') }

  before do
    @model = Model()
    @list = Toy::List.new(model, :games)
  end

  let(:model) { @model }
  let(:list)  { @list }

  it "has model" do
    list.model.should == model
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
    model.lists.keys.should include(:games)
  end

  it "adds attribute to model" do
    model.attributes.keys.should include(:game_ids)
  end
end