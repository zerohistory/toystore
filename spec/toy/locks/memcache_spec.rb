require 'helper'

describe Toy::Locks::Memcache do
  uses_constants('User')

  before do
    @lock = Toy::Lock.new(User, :test_lock, :store => :memcache)
    @lock.store.clear
  end

  it "should return true for setnx when value does not exist" do
    @lock.setnx('some_value').should be_true
  end

  xit "should return false for setnx when value already exists" do
    @lock.store[:test_lock] = 'another_value'
    @lock.setnx('some_value').should be_false
  end
end