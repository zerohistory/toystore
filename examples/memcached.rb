require 'pp'
require 'rubygems'
require 'toystore'
require 'adapter/memcached'

class GameList
  include Toy::Store
  store :memcached, Memcached.new

  attribute :source, Hash
end

list = GameList.create(:source => {'foo' => 'bar'})

pp list
pp GameList.get(list.id)

list.destroy

pp GameList.get(list.id)