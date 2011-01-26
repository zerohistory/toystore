$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'
require 'logger'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
log_path  = root_path.join('log')
log_path.mkpath

require 'rubygems'
require 'bundler'

Bundler.require(:default, :development)

require 'toy'
require 'adapter/memory'
require 'adapter/memcached'

require 'support/constants'
require 'support/identity_map_matcher'
require 'support/name_and_number_key_factory'

Logger.new(log_path.join('test.log')).tap do |log|
  LogBuddy.init(:logger => log)
  Toy.logger = log
end

$memcached = Memcached.new

Rspec.configure do |c|
  c.include(Support::Constants)
  c.include(IdentityMapMatcher)

  c.before(:each) do
    Toy.clear
    Toy.reset
  end
end