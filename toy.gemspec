# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'toy/version'

Gem::Specification.new do |s|
  s.name        = "toystore"
  s.version     = Toy::Version
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Geoffrey Dagley"]
  s.email       = ["gdagley@newtoyinc.com"]
  s.homepage    = "http://github.com/newtoy/toystore"
  s.summary     = "ORM for key-value stores"
  s.description = "ORM for key-value stores"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "simple_uuid"
  s.add_runtime_dependency "activemodel", '3'
  s.add_runtime_dependency "activesupport", '3'

  s.add_development_dependency "rspec"
  s.add_development_dependency "log_buddy"
  s.add_development_dependency "timecop"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  s.require_path = 'lib'
end