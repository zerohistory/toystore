require 'helper'

describe Toy::Lists do
  uses_constants('User', 'Game')

  it "defaults lists to empty hash" do
    User.lists.should == {}
  end

  describe "declaring a list" do
    before do
      @list = User.list(:games)
    end

    it "knows about its lists" do
      User.lists[:games].should == Toy::List.new(User, :games)
    end

    it "returns list" do
      @list.should == Toy::List.new(User, :games)
    end
    
    it "should pass options to list" do
      @list = User.list(:games, {:some => 'option'})
      @list.should == Toy::List.new(User, :games, {:some => 'option'})
    end
  end
end