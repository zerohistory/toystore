$:.unshift(File.expand_path('../../lib', __FILE__))
require 'toy'
require 'spec'
require 'models'

require File.expand_path('../../vendor/moneta/lib/moneta/file', __FILE__)
require File.expand_path('../../vendor/moneta/lib/moneta/redis', __FILE__)
require File.expand_path('../../vendor/moneta/lib/moneta/mongodb', __FILE__)

FileStore  = Moneta::File.new(:path => 'testing')
MongoStore = Moneta::MongoDB.new
RedisStore = Moneta::Redis.new

Spec::Runner.configure do |config|
  config.before(:each) do
    [FileStore, MongoStore, RedisStore].each(&:clear)
  end
end

def Model(name=nil, &block)
  klass = Class.new do
    include Toy::Store
    store RedisStore

    if name
      class_eval "def self.name; '#{name}' end"
      class_eval "def self.to_s; '#{name}' end"
    end
  end
  klass.class_eval(&block) if block_given?
  klass
end