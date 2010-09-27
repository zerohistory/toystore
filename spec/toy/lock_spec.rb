require 'helper'

describe Toy::Lock do
  uses_constants('User')

  before do
    User.store.clear
  end

  it "should default to use the store of the model" do
    lock = Toy::Lock.new(User, :test_lock)
    lock.store.should == User.store
  end

  it "should be able to pass options to a separate store" do
    lock = Toy::Lock.new(User, :test_lock, :store => :file, :store_options => {:path => 'testing'})
    adapter = lock.store.instance_variable_get("@adapter")
    adapter.should be_instance_of(Moneta::Adapters::File)
    adapter.instance_variable_get("@directory").should == 'testing'
  end

  it "should set the value to the expiration" do
    start = Time.now
    expiry = 15
    lock = Toy::Lock.new(User, :test_lock, :expiration => expiry)
    lock.lock do
      expiration = User.store[:test_lock].to_f
      expiration.should be_close((start + expiry).to_f, 2.0)
    end
  end

  it "should clean up after lock" do
    lock = Toy::Lock.new(User, :test_lock, :expiration => 15)
    lock.lock do
      sleep 1.1
    end

    User.store[:test_lock].should be_nil
  end

  it "should set value to 1 when no expiration is set" do
    lock = Toy::Lock.new(User, :test_lock)
    lock.lock do
      User.store[:test_lock].should == 1
    end
  end

  it "should let lock be gettable when lock is expired" do
    expiry = 15
    lock = Toy::Lock.new(User, :test_lock, :expiration => expiry, :timeout => 0.1)

    # create a fake lock in the past
    User.store[:test_lock] = Time.now - (expiry + 60)

    gotit = false
    lock.lock do
      gotit = true
    end

    # should get the lock because it has expired
    gotit.should be_true
  end

  it "should not let non-expired locks be gettable" do
    expiry = 15
    lock = Toy::Lock.new(User, :test_lock, :expiration => expiry, :timeout => 0.1)

    # create a fake lock
    User.store[:test_lock] = (Time.now + expiry).to_f

    gotit = false
    error = nil
    lambda {
      lock.lock do
        gotit = true
      end
    }.should raise_error(Toy::LockTimeout, 'Timeout on lock test_lock exceeded 0.1 sec')

    # should not have the lock
    gotit.should_not be_true
  end

  it "should not remove the key if lock is held past expiration" do
    lock = Toy::Lock.new(User, :test_lock, :expiration => 0.0)

    lock.lock do
      sleep 1.1
    end

    # lock value should still be set since the lock was held for more than the expiry
    User.store[:test_lock].should_not be_nil
  end
end