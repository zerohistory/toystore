require 'pp'
require 'rubygems'
require 'toystore'
require 'adapter/riak'

class GameList
  include Toy::Store
  store :riak, Riak::Client.new['adapter_example']

  attribute :source, Hash
end

list = GameList.create(:source => {'foo' => 'bar'})

pp list
pp GameList.get(list.id)

list.destroy

pp GameList.get(list.id)