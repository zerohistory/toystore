require 'helper'
require 'adapter/redis'

describe Toy::Locks::Redis do
  uses_constants('User')

  before do
    User.adapter(:redis, Redis.new)
    @lock_name = :test_lock
    @lock = Toy::Lock.new(User, @lock_name)
    @lock.adapter.clear
  end

  it_should_behave_like 'lock adapter'
end