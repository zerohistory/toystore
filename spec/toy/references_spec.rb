require 'helper'

describe Toy::References do
  uses_constants('User', 'Game')

  it "defaults references to empty hash" do
    User.references.should == {}
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
end