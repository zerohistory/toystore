require 'helper'

describe Toy::Lists do
  uses_constants('User', 'Game')

  describe "declaring a list" do
    before do
      User.list(:games)
    end

    it "knows about its lists" do
      User.lists[:games].should == Toy::List.new(User, :games)
    end
  end
end