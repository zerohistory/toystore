require 'helper'

describe Toy::IdentityMap do
  uses_constants('User', 'Skill')

  before do
    Toy.identity_map.clear
  end

  describe ".identity_map" do
    it "defaults to hash" do
      User.identity_map.should == {}
    end

    it "memoizes" do
      User.identity_map.should equal(User.identity_map)
    end
  end

  it "adds to map on save" do
    user = User.new
    user.save!
    user.should be_in_identity_map
  end

  it "adds to map on load" do
    user = User.load({'id' => '1'})
    user.should be_in_identity_map
  end

  it "removes from map on delete" do
    user = User.create
    user.should be_in_identity_map
    user.delete
    user.should_not be_in_identity_map
  end

  it "removes from map on destroy" do
    user = User.create
    user.should be_in_identity_map
    user.destroy
    user.should_not be_in_identity_map
  end

  describe ".get" do
    it "adds to map if not in map" do
      user = User.create
      user.identity_map.clear
      user.should_not be_in_identity_map
      user = User.get(user.id)
      user.should be_in_identity_map
    end

    it "returns from map if in map" do
      user = User.create
      user.should be_in_identity_map
      User.get(user.id).should equal(user)
    end

    it "does not query if in map" do
      user = User.create
      user.should be_in_identity_map
      user.stores.each do |store|
        store.should_not_receive(:read)
      end
      User.get(user.id).should equal(user)
    end
  end

  describe "#reload" do
    it "forces new query each time and skips the identity map" do
      user = User.create
      user.should be_in_identity_map
      User.store.should_receive(:read).with(user.store_key).and_return({})
      user.reload
    end
  end

  describe "identity map off" do
    it "does not add to map on save" do
      User.identity_map_off
      user = User.new
      user.save!
      user.should_not be_in_identity_map
    end

    it "does not add to map on load" do
      User.identity_map_off
      user = User.load('id' => '1')
      user.should_not be_in_identity_map
    end

    it "does not remove from map on delete" do
      user = User.create
      user.should be_in_identity_map
      User.identity_map_off
      user.delete
      user.should be_in_identity_map
    end

    it "does not remove from map on destroy" do
      user = User.create
      user.should be_in_identity_map
      User.identity_map_off
      user.destroy
      user.should be_in_identity_map
    end

    describe ".get" do
      it "does not add to map if not in map" do
        User.identity_map_off
        user = User.create
        user.should_not be_in_identity_map
        user = User.get(user.id)
        user.should_not be_in_identity_map
      end

      it "does not load from map if in map" do
        user = User.create
        user.should be_in_identity_map
        User.identity_map_off
        user.store.should_receive(:read).with(user.store_key).and_return(user.persisted_attributes)
        User.get(user.id)
      end
    end
  end

  describe ".without_identity_map" do
    describe "with identity map off" do
      it "turns identity map off, yields, and returns it to previous state" do
        User.identity_map_off
        User.should be_identity_map_off
        User.without_identity_map do
          user = User.create
          user.should_not be_in_identity_map
        end
        User.should be_identity_map_off
      end
    end

    describe "with identity map on" do
      it "turns identity map off, yields, and returns it to previous state" do
        User.should be_identity_map_on
        User.without_identity_map do
          user = User.create
          user.should_not be_in_identity_map
        end
        User.should be_identity_map_on
      end
    end
  end
end