require 'pathname'
require 'logger'

root_path   = Pathname(__FILE__).dirname.join('..').expand_path
lib_path    = root_path.join('lib')
log_path    = root_path.join('log')
moneta_path = root_path.join('vendor', 'moneta', 'lib')

log_path.mkpath

$:.unshift(lib_path, moneta_path)

require 'toy'
require 'spec'
require 'log_buddy'
require 'support/constants'

require 'moneta/file'
require 'moneta/redis'
require 'moneta/mongodb'

Log = Logger.new(log_path.join('test.log'))

LogBuddy.init :logger => Log

FileStore  = Moneta::File.new(:path => 'testing')
MongoStore = Moneta::MongoDB.new
RedisStore = Moneta::Redis.new

Spec::Runner.configure do |config|
  config.include(Support::Constants)

  config.before(:each) do
    [FileStore, MongoStore, RedisStore].each(&:clear)
  end
end