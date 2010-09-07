require 'helper'

describe Toy::Dirty do
  uses_constants('User', 'Game', 'Person')

  describe "#eql?" do
    it "returns true if same class and id" do
      User.new(:id => 1).should eql(User.new(:id => 1))
    end

    it "return false if different class" do
      User.new(:id => 1).should_not eql(Person.new(:id => 1))
    end

    it "returns false if different id" do
      User.new(:id => 1).should_not eql(User.new(:id => 2))
    end

    it "returns true if reference and target is same class and id" do
      Game.reference(:user)
      user = User.create
      game = Game.create(:user => user)
      user.should eql(game.user)
    end
  end

  describe "equal?" do
    it "returns true if same object" do
      user = User.create(:id => 1)
      user.should equal(user)
    end

    it "returns true if same object through proxy" do
      Game.reference(:user)
      user = User.create
      game = Game.create(:user => user)

      user.should equal(game.user)
      game.user.should equal(user)
    end

    it "returns false if not same object" do

    end
  end
end