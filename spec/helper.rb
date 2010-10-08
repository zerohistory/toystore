require 'bundler/setup'
require 'pathname'
require 'logger'

root_path   = Pathname(__FILE__).dirname.join('..').expand_path
lib_path    = root_path.join('lib')
log_path    = root_path.join('log')

log_path.mkpath

$:.unshift(lib_path)

require 'toy'
require 'spec'
require 'timecop'
require 'log_buddy'
require 'support/constants'
require 'support/name_and_number_key_factory'
require 'support/identity_map_matcher'
require 'adapter/memory'

Logger.new(log_path.join('test.log')).tap do |log|
  LogBuddy.init(:logger => log)
  Toy.logger = log
end

Spec::Runner.configure do |config|
  config.include(Support::Constants)
  config.include(IdentityMapMatcher)

  config.before(:each) do
    Toy.clear
    Toy.reset
  end
end