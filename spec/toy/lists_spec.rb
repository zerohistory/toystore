require 'helper'

describe Toy::Lists do
  uses_constants('User', 'Game')

  describe "including lists module" do
    before do
      @klass = Class.new do
        include Toy::Lists
      end
    end

    it "adds list accessors module" do
      @klass.const_get('ListAccessors').should be_true
    end
  end

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
  end
end