$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "toystore/version"
 
task :build do
  system "gem build toystore.gemspec"
end
 
task :release => :build do
  system "gem push toystore-#{Toystore::VERSION}"
end