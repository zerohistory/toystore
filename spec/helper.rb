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
require 'timecop'
require 'log_buddy'
require 'support/constants'
require 'support/name_and_number_key_factory'

require 'moneta'
require 'moneta/adapters/file'
require 'moneta/adapters/redis'
require 'moneta/adapters/mongodb'

FileStore = Moneta::Builder.new do
  run Moneta::Adapters::File, :path => 'testing'
end

MongoStore = Moneta::Builder.new do
  run Moneta::Adapters::MongoDB
end

RedisStore = Moneta::Builder.new do
  run Moneta::Adapters::Redis
end

Logger.new(log_path.join('test.log')).tap do |log|
  LogBuddy.init(:logger => log)
  Toy.logger = log
end

Toy.store  = RedisStore

Spec::Runner.configure do |config|
  config.include(Support::Constants)

  config.before(:each) do
    [FileStore, MongoStore, RedisStore].each(&:clear)
  end
end