require 'helper'

describe Toy do
  uses_constants('User', 'Game', 'Move')

  it "can encode to json" do
    Toy.encode({'foo' => 'bar'}).should == '{"foo":"bar"}'
  end

  it "can parse to json" do
    Toy.decode('{"foo":"bar"}').should == {'foo' => 'bar'}
  end

  it "can clear all the stores in one magical moment" do
    Game.embedded_list(:moves)
    user = User.create!
    game = Game.create!(:moves => [Move.new])
    Toy.clear
    User.get(user.id).should be_nil
    Game.get(game.id).should be_nil
  end
end