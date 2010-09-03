require 'helper'

describe Toy::List do
  uses_constants('Game', 'Move')

  before do
    @list = Game.embedded_list(:moves)
  end

  let(:list)  { @list }

  it "has model" do
    list.model.should == Game
  end

  it "has name" do
    list.name.should == :moves
  end

  it "has type" do
    list.type.should == Move
  end

  it "has key" do
    list.key.should == :move_attributes
  end

  it "has instance_variable" do
    list.instance_variable.should == :@_moves
  end

  it "adds list to model" do
    Game.embedded_lists.keys.should include(:moves)
  end

  it "adds attribute to model" do
    Game.attributes.keys.should include(:move_attributes)
  end

  it "adds reader method" do
    Game.new.should respond_to(:moves)
  end

  it "adds writer method" do
    Game.new.should respond_to(:moves=)
  end

  describe "#eql?" do
    it "returns true if same class, model, and name" do
      list.should eql(list)
    end

    it "returns false if not same class" do
      list.should_not eql({})
    end

    it "returns false if not same model" do
      list.should_not eql(Toy::List.new(Move, :moves))
    end

    it "returns false if not the same name" do
      list.should_not eql(Toy::List.new(Game, :recent_moves))
    end
  end

  describe "setting list type" do
    before do
      @list = Game.list(:recent_moves, Move)
    end
    let(:list) { @list }

    it "uses type provided instead of inferring from name" do
      list.type.should be(Move)
    end

    it "works properly when reading and writing" do
      game = Game.create
      move = Move.create
      game.recent_moves         = [move]
      game.recent_moves.should == [move]
    end
  end

  describe "list reader" do
    before do
      @move = Move.new
      @game = Game.create(:move_attributes => [@move.attributes])
    end

    it "returns instances" do
      @game.moves.should == [@move]
    end

    it "sets reference to parent for each instance" do
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
    end
  end

  describe "list writer (with instances)" do
    before do
      @move1 = Move.new
      @move2 = Move.new
      @game  = Game.create(:moves => [@move2])
    end

    it "set attribute" do
      @game.move_attributes.should == [@move2.attributes]
    end

    it "unmemoizes reader" do
      @game.moves.should == [@move2]
      @game.moves         = [@move1]
      @game.moves.should == [@move1]
    end

    it "sets reference to parent for each instance" do
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
    end
  end

  describe "list writer (with hashes)" do
    before do
      @move1 = Move.new
      @move2 = Move.new
      @game  = Game.create(:moves => [@move2.attributes])
    end

    it "set attribute" do
      @game.move_attributes.should == [@move2.attributes]
    end

    it "unmemoizes reader" do
      @game.moves.should == [@move2]
      @game.moves         = [@move1.attributes]
      @game.moves.should == [@move1]
    end

    it "sets reference to parent for each instance" do
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
    end
  end

  describe "list#reset" do
    before do
      @move = Move.new
      @game = Game.create(:move_attributes => [@move.attributes])
    end

    it "unmemoizes the list" do
      @game.moves.should == [@move]
      @game.moves.reset
      Move.should_receive(:load).and_return(@move)
      @game.moves.should == [@move]
    end

    it "should be reset when owner is reloaded" do
      @game.moves.should == [@move]
      @game.reload
      Move.should_receive(:load).and_return(@move)
      @game.moves.should == [@move]
    end
  end

  describe "list#push" do
    before do
      @move = Move.new
      @game = Game.create
      @game.moves.push(@move)
    end

    it "adds attributes to attribute" do
      @game.move_attributes.should == [@move.attributes]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @game.moves.push(Game.new)
      }.should raise_error(ArgumentError, "Move expected, but was Game")
    end

    it "sets reference to parent" do
      # right now pushing a move adds a different instance to the proxy
      # so i'm checking that it adds reference to both
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
      @move.parent_reference.should == @game
    end

    it "marks instances as persisted when parent saved" do
      @game.save
      @game.moves.each do |move|
        move.should be_persisted
      end
    end

    it "works with hashes" do
      @game.moves = []
      move = Move.new
      @game.moves.push(move.attributes)
      @game.moves.should == [move]
    end
  end

  describe "list#<<" do
    before do
      @move = Move.new
      @game = Game.create
      @game.moves << @move
    end

    it "adds attributes to attribute" do
      @game.move_attributes.should == [@move.attributes]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @game.moves << Game.new
      }.should raise_error(ArgumentError, "Move expected, but was Game")
    end

    it "sets reference to parent" do
      # right now pushing a move adds a different instance to the proxy
      # so i'm checking that it adds reference to both
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
      @move.parent_reference.should == @game
    end

    it "marks instances as persisted when parent saved" do
      @game.save
      @game.moves.each do |move|
        move.should be_persisted
      end
    end

    it "works with hashes" do
      @game.moves = []
      move = Move.new
      @game.moves << move.attributes
      @game.moves.should == [move]
    end
  end

  describe "list#concat" do
    before do
      @move1 = Move.new
      @move2 = Move.new
      @game  = Game.create
      @game.moves.concat(@move1, @move2)
    end

    it "adds attributes to attribute" do
      @game.move_attributes.should == [@move1.attributes, @move2.attributes]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @game.moves.concat(Game.new, Move.new)
      }.should raise_error(ArgumentError, "Move expected, but was Game")
    end

    it "sets reference to parent" do
      # right now pushing a move adds a different instance to the proxy
      # so i'm checking that it adds reference to both
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
      @move1.parent_reference.should == @game
      @move2.parent_reference.should == @game
    end

    it "marks instances as persisted when parent saved" do
      @game.save
      @game.moves.each do |move|
        move.should be_persisted
      end
    end

    it "works with hashes" do
      @game.moves = []
      move = Move.new
      @game.moves.concat(move.attributes)
      @game.moves.should == [move]
    end
  end

  describe "list#concat (with array)" do
    before do
      @move1 = Move.new
      @move2 = Move.new
      @game  = Game.create
      @game.moves.concat([@move1, @move2])
    end

    it "adds id to attribute" do
      @game.move_attributes.should == [@move1.attributes, @move2.attributes]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @game.moves.concat([Game.new, Move.new])
      }.should raise_error(ArgumentError, "Move expected, but was Game")
    end

    it "sets reference to parent" do
      # right now pushing a move adds a different instance to the proxy
      # so i'm checking that it adds reference to both
      @game.moves.each do |move|
        move.parent_reference.should == @game
      end
      @move1.parent_reference.should == @game
      @move2.parent_reference.should == @game
    end

    it "marks instances as persisted when parent saved" do
      @game.save
      @game.moves.each do |move|
        move.should be_persisted
      end
    end
  end

  shared_examples_for("embedded_list#create") do
    it "creates instance" do
      @move.should be_persisted
    end

    it "assigns reference to parent" do
      @move.parent_reference.should == @game
    end

    it "assigns id" do
      @move.id.should_not be_nil
    end

    it "adds attributes to attribute" do
      @game.move_attributes.should == [@move.attributes]
    end

    it "adds instance to reader" do
      @game.moves.should == [@move]
    end

    it "marks instance as persisted" do
      @move.should be_persisted
    end
  end

  describe "list#create" do
    before do
      @game = Game.create
      @move = @game.moves.create
    end

    it_should_behave_like "embedded_list#create"
  end

  describe "list#create (with attributes)" do
    before do
      Move.attribute(:move_index, Integer)
      @game = Game.create
      @move = @game.moves.create(:move_index => 0)
    end

    it_should_behave_like "embedded_list#create"

    it "sets attributes on instance" do
      @move.move_index.should == 0
    end
  end

  describe "list#create (invalid)" do
    before do
      @game = Game.create
      @game.moves.should_not_receive(:push)
      @game.moves.should_not_receive(:reset)
      @game.should_not_receive(:reload)
      @game.should_not_receive(:save)

      Move.attribute(:move_index, Integer)
      Move.validates_presence_of(:move_index)

      @move = @game.moves.create
    end

    it "returns instance" do
      @move.should be_instance_of(Move)
    end

    it "is not persisted" do
      @move.should_not be_persisted
    end

    it "assigns reference to parent" do
      @move.parent_reference.should == @game
    end
  end

  describe "list#destroy" do
    before do
      Move.attribute(:move_index, Integer)
      @game = Game.create
      @move1 = @game.moves.create(:move_index => 0)
      @move2 = @game.moves.create(:move_index => 1)
    end

    it "should take multiple ids" do
      @game.moves.destroy(@move1.id, @move2.id)
      @game.moves.should be_empty
      @game.reload
      @game.moves.should be_empty
    end

    it "should take an array of ids" do
      @game.moves.destroy([@move1.id, @move2.id])
      @game.moves.should be_empty
      @game.reload
      @game.moves.should be_empty
    end

    it "should take a block to filter on" do
      @game.moves.destroy { |move| move.move_index == 1 }
      @game.moves.should == [@move1]
      @game.reload
      @game.moves.should == [@move1]
    end
  end

  describe "list#each" do
    before do
      @move1 = Move.new
      @move2 = Move.new
      @game  = Game.create(:moves => [@move1, @move2])
    end

    it "iterates through each instance" do
      moves = []
      @game.moves.each do |move|
        moves << move
      end
      moves.should == [@move1, @move2]
    end
  end

  describe "enumerating" do
    before do
      Move.attribute(:move_index, Integer)
      @move1 = Move.new(:move_index => 0)
      @move2 = Move.new(:move_index => 1)
      @game  = Game.create(:moves => [@move1, @move2])
    end

    it "works" do
      @game.moves.select { |move| move.move_index > 0 }.should == [@move2]
      @game.moves.reject { |move| move.move_index > 0 }.should == [@move1]
    end
  end

  describe "list#include?" do
    before do
      @move1 = Move.new
      @move2 = Move.new
      @game = Game.create(:moves => [@move1])
    end

    it "returns true if instance in association" do
      @game.moves.should include(@move1)
    end

    it "returns false if instance not in association" do
      @game.moves.should_not include(@move2)
    end

    it "returns false for nil" do
      @game.moves.should_not include(nil)
    end
  end

  describe "list with block" do
    before do
      Move.attribute(:old, Boolean)
      Game.embedded_list(:moves) do
        def old
          target.select { |move| move.old? }
        end
      end

      @move_new = Move.create(:old => false)
      @move_old = Move.create(:old => true)
      @game     = Game.create(:moves => [@move_new, @move_old])
    end

    it "extends block methods onto proxy" do
      @game.moves.should respond_to(:old)
      @game.moves.old.should == [@move_old]
    end
  end

  describe "list extension with :extensions option" do
    before do
      old_module = Module.new do
        def old
          target.select { |m| m.old? }
        end
      end

      recent_proc = Proc.new do
        def recent
          target.select { |m| !m.old? }
        end
      end

      Move.attribute(:old, Boolean)
      Game.embedded_list(:moves, :extensions => [old_module, recent_proc])

      @move_new = Move.new(:old => false)
      @move_old = Move.new(:old => true)
      @game     = Game.create(:moves => [@move_new, @move_old])
    end

    it "extends modules" do
      @game.moves.should respond_to(:old)
      @game.moves.old.should    == [@move_old]
    end

    it "extends procs" do
      @game.moves.should respond_to(:recent)
      @game.moves.recent.should == [@move_new]
    end
  end

  describe "list#get" do
    before do
      @game = Game.create
      @move = @game.moves.create
    end

    it "should not find items that don't exist" do
      @game.moves.get('does-not-exist').should be_nil
    end

    it "should find items that are in list" do
      @game.moves.get(@move.id).should == @move
    end
  end
end