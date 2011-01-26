require 'pp'
require 'rubygems'
require 'toystore'
require 'adapter/redis'

class User
  include Toy::Store
  store :redis, Redis.new

  attribute :name, String
end

user = User.create(:name => 'John')

pp user
pp User.get(user.id)

user.destroy

pp User.get(user.id)