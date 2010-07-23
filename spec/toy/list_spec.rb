require 'helper'

describe Toy::List do
  before  { class ::Game; include Toy::Store end }
  after   { Object.send :remove_const, 'Game' if defined?(::Game) }

  let(:model)     { Model() }
  let(:attr_name) { :games }
  let(:list) { Toy::List.new(model, attr_name) }

  it "has model" do
    list.model.should == model
  end

  it "has name" do
    list.name.should == attr_name
  end

  it "has type" do
    list.type.should == Game
  end

  it "has key" do
    list.key.should == :game_ids
  end
end