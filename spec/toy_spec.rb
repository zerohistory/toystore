require 'helper'

describe Toy do
  uses_constants('User', 'Game', 'Move')

  describe ".clear" do
    it "can clear all the stores in one magical moment" do
      Game.embedded_list(:moves)
      user = User.create!
      game = Game.create!(:moves => [Move.new])
      Toy.clear
      User.get(user.id).should be_nil
      Game.get(game.id).should be_nil
    end

    it "does not raise error when no default store set" do
      klass = Class.new { include Toy::Store }
      lambda { Toy.clear }.should_not raise_error
    end
  end
end