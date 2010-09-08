require 'helper'

describe Toy::Lists do
  uses_constants('User', 'Game', 'Move')

  it "defaults lists to empty hash" do
    User.lists.should == {}
  end

  it "does not share with embedded lists" do
    Game.embedded_list(:moves)
    Game.lists.should == {}
  end

  describe "declaring a list" do
    describe "using conventions" do
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

    describe "with type" do
      before do
        @list = User.list(:active_games, Game)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Game)
      end

      it "sets options to hash" do
        list.options.should be_instance_of(Hash)
      end
    end

    describe "with options" do
      before do
        @list = User.list(:games, :dependent => true)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Game)
      end

      it "sets options" do
        list.options.should have_key(:dependent)
        list.options[:dependent].should be_true
      end
    end

    describe "with type and options" do
      before do
        @list = User.list(:active_games, Game, :dependent => true)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Game)
      end

      it "sets options" do
        list.options.should have_key(:dependent)
        list.options[:dependent].should be_true
      end
    end
  end
end