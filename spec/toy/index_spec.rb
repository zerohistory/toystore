require 'helper'

describe Toy::Index do
  uses_constants('User', 'Student', 'Friendship')

  before do
    User.attribute(:ssn, String)
    @index = User.index(:ssn)
  end
  let(:index) { @index }

  it "has a model" do
    index.model.should == User
  end

  it "has a name" do
    index.name.should == :ssn
  end

  it "raises error if attribute does not exist" do
    lambda {
      User.index :student_id
    }.should raise_error(ArgumentError, "No attribute student_id for index")
  end

  it "has a sha1'd key for a value" do
    index.key('some_value').should == 'User:ssn:8c818171573b03feeae08b0b4ffeb6999e3afc05'
  end

  it "adds index to model" do
    User.indices.keys.should include(:ssn)
  end

  describe "#eql?" do
    it "returns true if same class, model, and name" do
      index.should eql(index)
    end

    it "returns false if not same class" do
      index.should_not eql({})
    end

    it "returns false if not same model" do
      Student.attribute :ssn, String
      index.should_not eql(Toy::Index.new(Student, :ssn))
    end

    it "returns false if not the same name" do
      User.attribute :student_id, String
      index.should_not eql(Toy::Index.new(User, :student_id))
    end
  end

  describe "single key" do
    describe "creating with index" do
      before do
        @user = User.create(:ssn => '555-00-1234')
      end
      let(:user) { @user }

      it "creates key for indexed value" do
        User.adapter.should be_key("User:ssn:f6edc9155d79e311ad2d4a6e1b54004f31497f4c")
      end

      it "adds instance id to index array" do
        User.get_index(:ssn, '555-00-1234').should == [user.id]
      end
    end

    describe "creating second record for same index value" do
      before do
        @user1 = User.create(:ssn => '555-00-1234')
        @user2 = User.create(:ssn => '555-00-1234')
      end

      it "adds both instances to index" do
        User.get_index(:ssn, '555-00-1234').should == [@user1.id, @user2.id]
      end
    end

    describe "destroying with index" do
      before do
        @user = User.create(:ssn => '555-00-1234')
        @user.destroy
      end

      it "removes id from index" do
        User.get_index(:ssn, '555-00-1234').should == []
      end
    end

    describe "updating record and changing indexed value" do
      before do
        @user = User.create(:ssn => '555-00-1234')
        @user.update_attributes(:ssn => '555-00-4321')
      end

      it "removes from old index" do
        User.get_index(:ssn, '555-00-1234').should == []
      end

      it "adds to new index" do
        User.get_index(:ssn, '555-00-4321').should == [@user.id]
      end
    end

    describe "updating record without changing indexed value" do
      before do
        @user = User.create(:ssn => '555-00-1234')
        @user.update_attributes(:ssn => '555-00-1234')
      end

      it "leaves index alone" do
        User.get_index(:ssn, '555-00-1234').should == [@user.id]
      end
    end

    describe "first by index" do
      it "should not find values that are not in index" do
        User.first_by_ssn('does-not-exist').should be_nil
      end

      it "should find indexed value" do
        user = User.create(:ssn => '555-00-1234')
        User.first_by_ssn('555-00-1234').should == user
      end
    end

    describe "first or new by index" do
      it "initializes if not existing" do
        user = User.first_or_new_by_ssn('does-not-exist')
        user.ssn.should == 'does-not-exist'
        user.should_not be_persisted
      end

      it "returns if existing" do
        user = User.create(:ssn => '555-00-1234')
        User.first_or_new_by_ssn('555-00-1234').should == user
      end
    end

    describe "first or create by index" do
      it "creates if not existing" do
        user = User.first_or_create_by_ssn('does-not-exist')
        user.ssn.should == 'does-not-exist'
        user.should be_persisted
      end

      it "returns if existing" do
        user = User.create(:ssn => '555-00-1234')
        User.first_or_create_by_ssn('555-00-1234').should == user
      end
    end
  end

  describe "array key" do
    before do
      User.list :friendships
      Friendship.list :users
      Friendship.index :user_ids
      @user1 = User.create(:ssn => '555-00-1234')
      @user2 = User.create(:ssn => '555-00-9876')
      @friendship = Friendship.create(:user_ids => [@user1.id, @user2.id])
    end
    let(:user1) { @user1 }
    let(:user2) { @user2 }
    let(:friendship) { @friendship }

    describe "creating with index" do
      it "creates key for indexed values sorted" do
        sha_value = Digest::SHA1.hexdigest([user1.id, user2.id].sort.join(''))
        Friendship.adapter.should be_key("Friendship:user_ids:#{sha_value}")
      end

      it "adds instance id to index array" do
        Friendship.get_index(:user_ids, [user1.id, user2.id]).should == [friendship.id]
        Friendship.get_index(:user_ids, [user2.id, user1.id]).should == [friendship.id]
      end
    end

    describe "destroying with index" do
      before do
        friendship.destroy
      end

      it "removes id from index" do
        Friendship.get_index(:user_ids, [user2.id, user1.id]).should == []
      end
    end

    describe "first by index" do
      it "should not find values that are not in index" do
        Friendship.first_by_user_ids([user1.id, 'does-not-exist']).should be_nil
      end

      it "should find indexed value" do
        Friendship.first_by_user_ids([user1.id, user2.id]).should == friendship
        Friendship.first_by_user_ids([user2.id, user1.id]).should == friendship
      end
    end

    describe "first or new by index" do
      it "initializes if not existing" do
        new_friend = User.create(:ssn => '555-00-1928')
        new_friendship = Friendship.first_or_new_by_user_ids([user1.id, new_friend.id])
        new_friendship.user_ids.sort.should == [user1.id, new_friend.id].sort
        new_friendship.should_not be_persisted
      end

      it "returns if existing" do
        Friendship.first_or_new_by_user_ids([user1.id, user2.id]).should == friendship
        Friendship.first_or_new_by_user_ids([user2.id, user1.id]).should == friendship
      end
    end

    describe "first or create by index" do
      it "creates if not existing" do
        new_friend = User.create(:ssn => '555-00-1928')
        new_friendship = Friendship.first_or_create_by_user_ids([user1.id, new_friend.id])
        new_friendship.user_ids.sort.should == [user1.id, new_friend.id].sort
        new_friendship.should be_persisted
      end

      it "returns if existing" do
        Friendship.first_or_create_by_user_ids([user1.id, user2.id]).should == friendship
        Friendship.first_or_create_by_user_ids([user2.id, user1.id]).should == friendship
      end
    end
  end
end