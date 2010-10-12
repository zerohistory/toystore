require 'helper'
require 'adapter/memcached'

describe Toy::Locks::Memcached do
  uses_constants('User')

  before do
    User.adapter(:memcached, Memcached.new('localhost:11211', :namespace => 'moneta_spec'))
    @lock_name = :test_lock
    @lock = Toy::Lock.new(User, @lock_name)
    @lock.adapter.clear
  end

  it_should_behave_like 'lock adapter'
end