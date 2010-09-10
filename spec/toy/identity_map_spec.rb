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
      user.store.should_not_receive(:[])
      User.get(user.id).should equal(user)
    end
  end

  describe "#reload" do
    it "forces new query each time and skips the identity map" do
      user = User.create
      user.should be_in_identity_map
      User.store.should_receive(:[]).with("User:#{user.id}")
      user.reload
    end
  end
end