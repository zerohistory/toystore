# encoding: UTF-8
require File.expand_path('../lib/toy/version', __FILE__)

Gem::Specification.new do |s|
  s.name               = 'toystore'
  s.homepage           = 'http://github.com/newtoy/toystore'
  s.summary            = 'Object mapper for anything'
  s.require_path       = 'lib'
  s.authors            = ['Geoffrey Dagley', 'John Nunemaker']
  s.email              = ['gdagley@newtoyinc.com', 'nunemaker@gmail.com']
  s.version            = Toy::Version
  s.platform           = Gem::Platform::RUBY
  s.files              = Dir.glob("{examples,lib,spec}/**/*") + %w[LICENSE README.md]

  s.add_dependency 'simple_uuid'
  s.add_dependency 'activemodel', '3'
  s.add_dependency 'activesupport', '3'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '1.3.0'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'tzinfo'
  s.add_development_dependency 'log_buddy'
  s.add_development_dependency 'diff-lcs'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'SystemTimer'
  s.add_development_dependency 'memcached'
end