require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'spec/rake/spectask'
require File.expand_path('../lib/toy/version', __FILE__)

def gemspec
  @gemspec ||= begin
    file = File.expand_path('../toystore.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

Rake::TestTask.new do |t|
  t.ruby_opts << '-rubygems'
  t.test_files = ['test/lint_test.rb']
  t.verbose    = true
end

Spec::Rake::SpecTask.new do |t|
  t.ruby_opts << '-rubygems'
  t.verbose = true
end
task :default => :spec
task :default => :test

desc 'Vaildate the gem specification'
task :gemspec do
  gemspec.validate
end

desc 'Builds the gem'
task :build => :gemspec do
  sh "gem build toy.gemspec"
end

desc 'Builds and installs the gem'
task :install => :build do
  sh "gem install toy-#{Toy::Version}"
end

desc 'Tags version, pushes to remote, and pushes gem'
task :release => :build do
  sh "git tag v#{Toy::Version}"
  sh "git push origin master"
  sh "git push origin v#{Toy::Version}"
  sh "gem push toy-#{Toy::Version}.gem"
end
