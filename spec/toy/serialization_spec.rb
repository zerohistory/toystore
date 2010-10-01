require 'helper'

describe Toy::Serialization do
  uses_constants('User', 'Game', 'Move', 'Tile')

  before do
    User.attribute :name, String
    User.attribute :age, Integer
  end

  it "serializes to json" do
    doc = User.new(:name => 'John', :age => 28)
    Toy.decode(doc.to_json).should == {
      'user' => {
        'name' => 'John',
        'id' => doc.id,
        'age' => 28
      }
    }
  end

  it "serializes to xml" do
    doc = User.new(:name => 'John', :age => 28)
    Hash.from_xml(doc.to_xml).should == {
      'user' => {
        'name' => 'John',
        'id' => doc.id,
        'age' => 28
      }
    }

  end

  it "correctly serializes methods" do
    User.class_eval do
      def foo
        {'foo' => 'bar'}
      end
    end
    json = User.new.to_json(:methods => [:foo])
    Toy.decode(json)['user']['foo'].should == {'foo' => 'bar'}
  end

  it "allows using :only" do
    user = User.new
    json = user.to_json(:only => :id)
    Toy.decode(json).should == {'user' => {'id' => user.id}}
  end

  it "allows using :only with strings" do
    user = User.new
    json = user.to_json(:only => 'id')
    Toy.decode(json).should == {'user' => {'id' => user.id}}
  end

  it "allows using :except" do
    user = User.new
    json = user.to_json(:except => :id)
    Toy.decode(json)['user'].should_not have_key('id')
  end

  it "allows using :except with strings" do
    user = User.new
    json = user.to_json(:except => 'id')
    Toy.decode(json)['user'].should_not have_key('id')
  end

  describe "serializing with embedded documents" do
    before do
      Game.reference(:creator, User)

      Move.attribute(:index,  Integer)
      Move.attribute(:points, Integer)
      Move.attribute(:words,  Array)

      Tile.attribute(:row,    Integer)
      Tile.attribute(:column, Integer)
      Tile.attribute(:index,  Integer)

      Game.embedded_list(:moves)
      Move.embedded_list(:tiles)

      @user = User.create
      @game = Game.create!(:creator => @user, :move_attributes => [
        :index            => 0,
        :points           => 15,
        :tile_attributes => [
          {:column => 7, :row => 7, :index => 23},
          {:column => 8, :row => 7, :index => 24},
        ],
      ])
    end

    it "includes all embedded attributes by default" do
      move = @game.moves.first
      tile1 = move.tiles[0]
      tile2 = move.tiles[1]
      Toy.decode(@game.to_json).should == {
        'game' => {
          'id'         => @game.id,
          'creator_id' => @user.id,
          'moves'      => [
            {
              'id'     => move.id,
              'index'  => 0,
              'points' => 15,
              'words'  => [],
              'tiles'  => [
                {'id' => tile1.id, 'column' => 7, 'row' => 7, 'index' => 23},
                {'id' => tile2.id, 'column' => 8, 'row' => 7, 'index' => 24},
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

  describe "serializing parent relationships" do
    before do
      Game.embedded_list :moves
      Move.parent_reference :game
    end

    it "should include references" do
      game = Game.create
      move = game.moves.create

      Toy.decode(move.to_json(:include => [:game])).should == {
        'move' => {
          'id' => move.id,
          'game' => {
            'id' => game.id,
            'moves' => [{
              'id' => move.id
            }]
          }
        }
      }
    end
  end

  describe "serializing specific attributes" do
    before do
      Move.attribute(:index,  Integer)
      Move.attribute(:points, Integer)
      Move.attribute(:words,  Array)
    end

    it "should default to all attributes" do
      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      move.serializable_attributes.should == [:id, :index, :points, :words]
    end

    it "should be set per model" do
      Move.class_eval do
        def serializable_attributes
          attribute_names = super - [:index]
          attribute_names
        end
      end

      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      move.serializable_attributes.should == [:id, :points, :words]
    end

    it "should only serialize specified attributes" do
      Move.class_eval do
        def serializable_attributes
          attribute_names = super - [:index]
          attribute_names
        end
      end

      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      Toy.decode(move.to_json).should == {
       'move' => {
         'id'     => move.id,
         'points' => 15,
         'words'  => ["QI", "XI"]
        }
      }
    end

    it "should serialize additional methods along with attributes" do
      Move.class_eval do
        def serializable_attributes
          attribute_names = super + [:calculated_attribute]
          attribute_names
        end

        def calculated_attribute
          'some value'
        end
      end

      move = Move.new(:index => 0, :points => 15, :words => ['QI', 'XI'])
      Toy.decode(move.to_json).should == {
       'move' => {
         'id'                   => move.id,
         'index'                => 0,
         'points'               => 15,
         'words'                => ["QI", "XI"],
         'calculated_attribute' => 'some value'
        }
      }
    end
  end

  describe "#serializable_hash" do
    context "with embedded list" do
      before do
        Game.embedded_list :moves
        Move.parent_reference :game

        @game = Game.create
        @move = game.moves.create
      end
      let(:game) { @game }

      it "returns a hash the whole way through" do
        game.serializable_hash.should == {
          'id' => game.id,
          'moves' => [
            {'id' => game.moves.first.id}
          ]
        }
      end

      it "allows using only with embedded" do
        game.serializable_hash(:only => :moves).should == {
          'moves' => [
            {'id' => game.moves.first.id}
          ]
        }
      end

      it "allows using except to not include embedded" do
        game.serializable_hash(:except => :moves).should == {
          'id' => game.id,
        }
      end
    end

    context "with method that is another toystore object" do
      before do
        Game.reference(:creator, User)
        @game = Game.create(:creator => User.create)
      end
      let(:game) { @game }

      it "returns serializable hash of object" do
        game.serializable_hash(:methods => [:creator]).should == {
          'id'         => game.id,
          'creator_id' => game.creator_id,
          'creator'    => {'id' => game.creator.id}
        }
      end
    end
  end
end