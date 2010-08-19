require 'helper'

describe Toy::List do
  uses_constants('User', 'Game', 'Move', 'Chat')

  before do
    @list = User.list(:games)
  end

  let(:list)  { @list }

  it "has model" do
    list.model.should == User
  end

  it "has name" do
    list.name.should == :games
  end

  it "has type" do
    list.type.should == Game
  end

  it "has key" do
    list.key.should == :game_ids
  end

  it "has instance_variable" do
    list.instance_variable.should == :@_games
  end

  it "adds list to model" do
    User.lists.keys.should include(:games)
  end

  it "adds attribute to model" do
    User.attributes.keys.should include(:game_ids)
  end

  it "adds reader method" do
    User.new.should respond_to(:games)
  end

  it "adds writer method" do
    User.new.should respond_to(:games=)
  end

  describe "#eql?" do
    it "returns true if same class, model, and name" do
      list.should eql(list)
    end

    it "returns false if not same class" do
      list.should_not eql({})
    end

    it "returns false if not same model" do
      list.should_not eql(Toy::List.new(Game, :users))
    end

    it "returns false if not the same name" do
      list.should_not eql(Toy::List.new(User, :moves))
    end
  end

  describe "dependent" do
    before do
      User.list :games, :dependent => true
      @game = Game.create
      @user = User.create(:game_ids => [@game.id])
    end

    it "should create a method to destroy games" do
      User.new.should respond_to(:destroy_games)
    end

    it "should remove the games" do
      user_id = @user.id
      game_id = @game.id
      @user.destroy
      User[user_id].should be_nil
      Game[game_id].should be_nil
    end
  end

  describe "setting list type" do
    before do
      @list = User.list(:active_games, Game)
    end
    let(:list) { @list }

    it "uses type provided instead of inferring from name" do
      list.type.should be(Game)
    end

    it "works properly when reading and writing" do
      user = User.create
      game = Game.create
      user.active_games         = [game]
      user.active_games.should == [game]
    end
  end

  describe "list reader" do
    before do
      @game = Game.create
      @user = User.create(:game_ids => [@game.id])
    end

    it "returns instances" do
      @user.games.should == [@game]
    end

    it "memoizes result" do
      @user.games.should == [@game]
      Game.should_not_receive(:get_multi)
      Game.should_not_receive(:get)
      @user.games.should == [@game]
    end

    it "does not query if ids attribute is blank" do
      user = User.create
      Game.should_not_receive(:get_multi)
      Game.should_not_receive(:get)
      user.games.should == []
    end
  end

  describe "list writer" do
    before do
      @game1 = Game.create
      @game2 = Game.create
      @user  = User.create(:game_ids => [@game1.id])
      @user.games = [@game2]
    end

    it "set attribute" do
      @user.game_ids.should == [@game2.id]
    end

    it "unmemoizes reader" do
      @user.games.should == [@game2]
      @user.games         = [@game1]
      @user.games.should == [@game1]
    end
  end

  describe "list#reset" do
    before do
      @game = Game.create
      @user = User.create(:game_ids => [@game.id])
    end

    it "unmemoizes the list" do
      games = [@game]
      @user.games.should == games
      @user.games.reset
      Game.should_receive(:get_multi).and_return(games)
      @user.games.should == games
    end
  end

  describe "list#push" do
    before do
      @game = Game.create
      @user = User.create
      @user.games.push(@game)
    end

    it "adds id to attribute" do
      @user.game_ids.should == [@game.id]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @user.games.push(Move.new)
      }.should raise_error(ArgumentError, "Game expected, but was Move")
    end
  end

  describe "list#<<" do
    before do
      @game = Game.create
      @user = User.create
      @user.games << @game
    end

    it "adds id to attribute" do
      @user.game_ids.should == [@game.id]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @user.games << Move.new
      }.should raise_error(ArgumentError, "Game expected, but was Move")
    end
  end

  describe "list#concat" do
    before do
      @game1 = Game.create
      @game2 = Game.create
      @user  = User.create
      @user.games.concat(@game1, @game2)
    end

    it "adds id to attribute" do
      @user.game_ids.should == [@game1.id, @game2.id]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @user.games.concat(Move.new)
      }.should raise_error(ArgumentError, "Game expected, but was Move")
    end
  end

  describe "list#concat (with array)" do
    before do
      @game1 = Game.create
      @game2 = Game.create
      @user  = User.create
      @user.games.concat([@game1, @game2])
    end

    it "adds id to attribute" do
      @user.game_ids.should == [@game1.id, @game2.id]
    end

    it "raises error if wrong type assigned" do
      lambda {
        @user.games.concat([Move.new])
      }.should raise_error(ArgumentError, "Game expected, but was Move")
    end
  end

  shared_examples_for("list#create") do
    it "creates instance" do
      @game.should be_persisted
    end

    it "adds id to attribute" do
      @user.game_ids.should == [@game.id]
    end

    it "adds instance to reader" do
      @user.games.should == [@game]
    end
  end

  describe "list#create" do
    before do
      @user = User.create
      @game = @user.games.create
    end

    it_should_behave_like "list#create"
  end

  describe "list#create (with attributes)" do
    before do
      Game.attribute(:move_count, Integer)
      @user = User.create
      @game = @user.games.create(:move_count => 10)
    end

    it_should_behave_like "list#create"

    it "sets attributes on instance" do
      @game.move_count.should == 10
    end
  end
  
  describe "list#create (does not persist)" do
    before do
      @user = User.create
      @user.games.should_not_receive(:push)
      @user.games.should_not_receive(:reset)
      @user.should_not_receive(:save)
      game = Game.new
      game.should_receive(:persisted?).and_return(false)
      Game.should_receive(:create).and_return(game)
      @game = @user.games.create
    end

    it "returns instance" do
      @game.should be_instance_of(Game)
    end
  end
  
  describe "list#create (with :inverse_of)" do
    before do
      Chat.reference(:game, Game)
      Game.list(:chats, Chat, :inverse_of => :game)
      @game = Game.create
      @chat = @game.chats.create
    end

    it "sets the inverse association" do
      # @game.chats.should include(@chat)
      @chat.game.should == @game
    end
  end

  describe "list#each" do
    before do
      @game1 = Game.create
      @game2 = Game.create
      @user = User.create(:game_ids => [@game1.id, @game2.id])
    end

    it "iterates through each instance" do
      games = []
      @user.games.each do |game|
        games << game
      end
      games.should == [@game1, @game2]
    end
  end

  describe "enumerating" do
    before do
      Game.attribute(:moves, Integer)
      @game1 = Game.create(:moves => 1)
      @game2 = Game.create(:moves => 2)
      @user = User.create(:game_ids => [@game1.id, @game2.id])
    end

    it "works" do
      @user.games.select { |g| g.moves > 1 }.should == [@game2]
      @user.games.reject { |g| g.moves > 1 }.should == [@game1]
    end
  end

  describe "list#include?" do
    before do
      @game1 = Game.create
      @game2 = Game.create
      @user = User.create(:game_ids => [@game1.id])
    end

    it "returns true if instance in association" do
      @user.games.should include(@game1)
    end

    it "returns false if instance not in association" do
      @user.games.should_not include(@game2)
    end

    it "returns false for nil" do
      @user.games.should_not include(nil)
    end
  end

  describe "list with block" do
    before do
      Move.attribute(:old, Boolean)
      User.list(:moves) do
        def old
          target.select { |m| m.old? }
        end
      end

      @move_new = Move.create(:old => false)
      @move_old = Move.create(:old => true)
      @user     = User.create(:moves => [@move_new, @move_old])
    end

    it "extends block methods onto proxy" do
      @user.moves.should respond_to(:old)
      @user.moves.old.should == [@move_old]
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
      User.list(:moves, :extensions => [old_module, recent_proc])

      @move_new = Move.create(:old => false)
      @move_old = Move.create(:old => true)
      @user     = User.create(:moves => [@move_new, @move_old])
    end

    it "extends modules" do
      @user.moves.should respond_to(:old)
      @user.moves.old.should    == [@move_old]
    end

    it "extends procs" do
      @user.moves.should respond_to(:recent)
      @user.moves.recent.should == [@move_new]
    end
  end
end