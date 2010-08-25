require 'helper'

describe Toy::Identity do
  uses_constants('User')
  
  describe "setting the key" do
    it "should set key factory to UUIDKeyFactory" do
      User.key(:uuid).should be_instance_of(Toy::Identity::UUIDKeyFactory)
    end

    it "should set key factory passed in factory" do
      factory = Toy::Identity::UUIDKeyFactory
      User.key(factory).should == factory
    end
    
    it "should use Toy.key_factory by default" do
      key_factory = mock
      Toy.key_factory = key_factory
      
      remove_constants("LeaderBoard")
      class LeaderBoard
        include Toy::Store
      end
      
      key_factory.should_receive(:next_key).and_return('some_key')
      LeaderBoard.next_key
      
      Toy.key_factory = nil
    end
  end
  
  describe ".next_key" do
    it "should call the next key on the key factory" do
      factory = Toy::Identity::UUIDKeyFactory
      factory.should_receive(:next_key).and_return('some_key')
      User.key(factory)
      User.next_key.should == 'some_key'
    end
    
    it "should raise an exception for nil key" do
      factory = Toy::Identity::UUIDKeyFactory
      factory.should_receive(:next_key).and_return(nil)
      User.key(factory)
      lambda { User.next_key }.should raise_error
    end
  end
  
  describe "initializing the id" do
    it "should pass use pass the new object" do
      remove_constants("NameAndNumberKeyFactory", "Piece")
      
      class NameAndNumberKeyFactory < Toy::Identity::AbstractKeyFactory
        def next_key(object)
          "#{object.name}-#{object.number}" unless object.name.nil? || object.number.nil?
        end
      end
      
      class Piece
        include Toy::Store
        attribute :name, String
        attribute :number, Integer
        key NameAndNumberKeyFactory.new
      end
      
      Piece.new(:name => 'Rook', :number => 1).id.should == 'Rook-1'
    end
    
  end
end
