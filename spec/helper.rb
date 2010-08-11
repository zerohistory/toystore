require 'pathname'

root_path   = Pathname(__FILE__).dirname.join('..').expand_path
lib_path    = root_path.join('lib')
moneta_path = root_path.join('vendor', 'moneta', 'lib')

$:.unshift(lib_path, moneta_path)

require 'toy'
require 'spec'
require 'log_buddy'
require 'support/constants'

require 'moneta/file'
require 'moneta/redis'
require 'moneta/mongodb'

LogBuddy.init

FileStore  = Moneta::File.new(:path => 'testing')
MongoStore = Moneta::MongoDB.new
RedisStore = Moneta::Redis.new

Spec::Runner.configure do |config|
  config.before(:each) do
    [FileStore, MongoStore, RedisStore].each(&:clear)
  end

  config.include(Support::Constants)
end