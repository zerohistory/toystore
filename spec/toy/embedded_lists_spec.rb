require 'helper'

describe Toy::Lists do
  uses_constants('Game', 'Move')

  it "defaults lists to empty hash" do
    Game.embedded_lists.should == {}
  end

  describe ".parent_reference" do
    before do
      Game.embedded_list(:moves)
    end

    context "with single name" do
      before do
        Move.parent_reference(:game)
        @game = Game.new
        @move = Move.new
      end

      it "defines method that calls parent_reference" do
        @move.parent_reference = @game
        @move.game.should == @game
      end

      it "defaults boolean method that checks parent_reference existence" do
        @move.game?.should be_false
        @move.parent_reference = @game
        @move.game?.should be_true
      end
    end

    context "with multiple names" do
      before do
        Move.parent_reference(:game, :yaypants)
        @game = Game.new
        @move = Move.new
      end

      it "defines method that calls parent_reference" do
        @move.parent_reference = @game
        @move.game.should == @game
        @move.yaypants.should == @game
      end

      it "defaults boolean method that checks parent_reference existence" do
        @move.game?.should be_false
        @move.yaypants?.should be_false
        @move.parent_reference = @game
        @move.game?.should be_true
        @move.yaypants?.should be_true
      end
    end
  end

  describe "declaring an embedded list" do
    describe "using conventions" do
      before do
        @list = Game.embedded_list(:moves)
      end

      it "knows about its lists" do
        Game.embedded_lists[:moves].should == Toy::EmbeddedList.new(Game, :moves)
      end

      it "returns list" do
        @list.should == Toy::EmbeddedList.new(Game, :moves)
      end
    end

    describe "with type" do
      before do
        @list = Game.embedded_list(:recent_moves, Move)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Move)
      end

      it "sets options to hash" do
        list.options.should be_instance_of(Hash)
      end
    end

    describe "with options" do
      before do
        @list = Game.embedded_list(:moves, :some_option => true)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Move)
      end

      it "sets options" do
        list.options.should have_key(:some_option)
        list.options[:some_option].should be_true
      end
    end

    describe "with type and options" do
      before do
        @list = Game.embedded_list(:recent_moves, Move, :some_option => true)
      end
      let(:list) { @list }

      it "sets type" do
        list.type.should be(Move)
      end

      it "sets options" do
        list.options.should have_key(:some_option)
        list.options[:some_option].should be_true
      end
    end
  end
end