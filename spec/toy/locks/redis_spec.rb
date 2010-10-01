require 'helper'

describe Toy::Locks::Redis do
  uses_constants('User')
  before do
    @lock = Toy::Lock.new(User, :test_lock, :store => :redis)
    @lock.store.clear
  end

  xit "should return true for setnx when value does not exist" do
    @lock.setnx('some_value').should be_true
    @lock.store[:test_lock].should == 'some_value'
  end

  xit "should return false for setnx when value already exists" do
    @lock.store[:test_lock] = 'another_value'
    @lock.setnx('some_value').should be_false
    @lock.store[:test_lock].should == 'some_value'
  end

  xit "should return previous value for getset" do
    @lock.store[:test_lock] = 'another_value'
    @lock.getset('some_value').should == 'another_value'
    @lock.store[:test_lock].should == 'some_value'
  end
end