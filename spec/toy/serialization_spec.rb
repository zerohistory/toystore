require 'helper'

describe Toy::Serialization do
  uses_constants('User', 'Game', 'Move', 'Tile')

  before do
    User.attribute :name, String
    User.attribute :age, Integer
  end

  it "serializes to json" do
    doc = User.new(:name => 'John', :age => 28)
    doc.to_json.should == %Q({"user":{"name":"John","id":"#{doc.id}","age":28}})
  end

  it "serializes to xml" do
    doc = User.new(:name => 'John', :age => 28)
    doc.to_xml.should == <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>John</name>
  <id>#{doc.id}</id>
  <age type="integer">28</age>
</user>
EOF
  end

  describe "serializing with embedded documents" do
    before do
      Game.reference(:creator, User)
      Game.embedded_list(:moves)

      Move.embedded_list(:tiles)
      Move.attribute(:index, Integer)
      Move.attribute(:points, Integer)
      Move.attribute(:words, Array)

      Tile.attribute(:coordinates, Hash)
      Tile.attribute(:index, Integer)

      @user = User.create
      @game = Game.new(:creator => @user)
      @move = Move.new(:index => 0, :points => 15, :tiles => [
        {:coordinates => {:x => 7, :y => 7}, :index => 23},
        {:coordinates => {:x => 8, :y => 7}, :index => 24},
      ])
      @game.moves.push(@move)
      @game.save!
    end

    it "includes all embedded attributes by default" do
      Toy.decode(@game.to_json(:include => [{:moves => :tiles}])).should == {
        'game' => {
          'id'              => @game.id,
          'creator_id'      => @user.id,
          'move_attributes' => [
            {
              'id'      => @game.moves.first.id,
              'index'   => 0,
              'points'  => 15,
              'tile_attributes' => [
                {'coordinates' => {'x' => 7, 'y' => 7}, 'index' => 23},
                {'coordinates' => {'x' => 8, 'y' => 7}, 'index' => 24},
              ]
            },
          ],
        }
      }
    end
  end

  describe "serializing relationships" do
    before do
      User.list :games, :inverse_of => :user
      Game.reference :user
    end

    it "should include references" do
      user = User.create(:name => 'John', :age => 28)
      game = user.games.create

      Toy.decode(game.to_json(:include => [:user])).should == {
        'game' => {
          'id'      => game.id,
          'user_id' => user.id,
          'user'    => {
            'name'     => 'John',
            'game_ids' => [game.id],
            'id'       => user.id,
            'age'      => 28,
          }
        }
      }
    end

    it "should include lists" do
      user = User.create(:name => 'John', :age => 28)
      game = user.games.create
      Toy.decode(user.to_json(:include => [:games])).should == {
        'user' => {
          'name'     => 'John',
          'game_ids' => [game.id],
          'id'       => user.id,
          'age'      => 28,
          'games'    => [{'id' => game.id, 'user_id' => user.id}],
        }
      }
    end

    it "should not cause circular reference JSON errors for references" do
      user = User.create(:name => 'John', :age => 28)
      game = user.games.create

      Toy.decode(ActiveSupport::JSON.encode(game.user)).should == {
        'user' => {
          'name'     => 'John',
          'game_ids' => [game.id],
          'id'       => user.id,
          'age'      => 28
        }
      }
    end

    it "should not cause circular reference JSON errors for references when called indirectly" do
      user = User.create(:name => 'John', :age => 28)
      game = user.games.create

      Toy.decode(ActiveSupport::JSON.encode([game.user])).should == [
        'user' => {
          'name'     => 'John',
          'game_ids' => [game.id],
          'id'       => user.id,
          'age'      => 28
        }
      ]
    end

    it "should not cause circular reference JSON errors for lists" do
      user = User.create(:name => 'John', :age => 28)
      game = user.games.create

      Toy.decode(ActiveSupport::JSON.encode(user.games)).should ==  [{
        'game' => {
          'id'      => game.id,
          'user_id' => user.id
        }
      }]
    end

    it "should not cause circular reference JSON errors for lists when called indirectly" do
      user = User.create(:name => 'John', :age => 28)
      game = user.games.create

      Toy.decode(ActiveSupport::JSON.encode({:games => user.games})).should ==  {
        'games' => [{
          'game' => {
            'id'      => game.id,
            'user_id' => user.id
          }
        }]
      }
    end
  end
end