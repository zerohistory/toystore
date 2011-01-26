# encoding: UTF-8
require File.expand_path('../lib/toy/version', __FILE__)

Gem::Specification.new do |s|
  s.name               = 'toystore'
  s.homepage           = 'http://github.com/newtoy/toystore'
  s.summary            = 'Object mapper for anything'
  s.require_path       = 'lib'
  s.authors            = ['Geoffrey Dagley', 'John Nunemaker']
  s.email              = ['gdagley@gmail.com', 'nunemaker@gmail.com']
  s.version            = Toy::Version
  s.platform           = Gem::Platform::RUBY
  s.files              = Dir.glob("{examples,lib,spec}/**/*") + %w[LICENSE README.md]

  s.add_dependency 'adapter',       '~> 0.5.1'
  s.add_dependency 'activemodel',   '~> 3.0.3'
  s.add_dependency 'activesupport', '~> 3.0.3'
  s.add_dependency 'simple_uuid',   '~> 0.1.1'
end