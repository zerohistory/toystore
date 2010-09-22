require 'helper'

describe Toy::Connection do
  uses_constants('User', 'Game', 'Move')

  before do
    Game.embedded_list(:moves)
    User.attribute(:name, String)
    User.attribute(:skills, Array)
    User.list(:games)

    @move = Move.new
    @game = Game.create(:moves => [@move])
    @user = User.create({
      :name   => 'John',
      :skills => ['looking awesome', 'growing beards'],
      :games  => [@game],
    })
  end
  let(:move)  { @move }
  let(:game)  { @game }
  let(:user)  { @user }

  describe "#clone" do
    it "returns new instance" do
      user.clone.should be_new_record
    end

    it "has no changes" do
      user.clone.should_not be_changed
    end

    it "is never destroyed" do
      user.destroy
      user.clone.should_not be_destroyed
    end

    it "clones the @attributes hash" do
      user.clone.instance_variable_get("@attributes").should_not equal(user.instance_variable_get("@attributes"))
    end

    it "copies the attributes" do
      user.clone.tap do |clone|
        clone.name.should == user.name
        clone.skills.should == user.skills
      end
    end

    it "clones duplicable attributes" do
      user.clone.skills.should_not equal(user.skills)
    end

    it "regenerates id" do
      user.clone.tap do |clone|
        clone.id.should_not be_nil
        clone.id.should_not == user.id
      end
    end

    it "clones list id attributes" do
      user.clone.game_ids.should_not equal(user.game_ids)
    end

    it "clones the list" do
      user.clone.games.should_not equal(user.games)
    end

    it "clones embedded list objects" do
      game.clone.moves.first.should_not equal(game.moves.first)
    end

    it "regenerates ids for embedded list objects" do
      game.clone.moves.first.id.should_not == game.moves.first.id
    end
  end
end