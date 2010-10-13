require 'helper'

describe Toy::Locks do
  uses_constants('User')

  before do
    User.adapter.clear
  end

  xit "should define a global lock" do
    User.lock :games, :global => true

    User.games_lock.lock do
      User.adapter['User:games_lock'].should_not be_nil
    end
  end

  xit "should use global lock for instances" do
    User.lock :games, :global => true
    user = User.new

    user.games_lock.lock do
      User.adapter['User:games_lock'].should_not be_nil
    end
  end

  xit "should use instance lock when not global" do
    User.lock :games
    user = User.new

    user.games_lock.lock do
      User.adapter["User:#{user.id}:games_lock"].should_not be_nil
    end
  end

  xit "should raise an error when lock is not defined" do
    lambda {
      User.obtain_lock(:games, 1)
    }.should raise_error(Toy::UndefinedLock, 'Undefined lock :games for class User')
  end

  xit "should obtain lock for specific id" do
    User.lock :games
    User.obtain_lock(:games, 1) do
      User.adapter['User:1:games_lock'].should_not be_nil
    end
  end

  xit "should release lock for specific id" do
    User.lock :games
    User.obtain_lock(:games, 1) do
      sleep 1.1
    end
    User.adapter['User:1:games_lock'].should be_nil
  end
end