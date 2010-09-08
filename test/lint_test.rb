require 'bundler/setup'
require 'pathname'

root_path   = Pathname(__FILE__).dirname.join('..').expand_path
lib_path    = root_path.join('lib')
moneta_path = root_path.join('vendor', 'moneta', 'lib')

$:.unshift(lib_path, moneta_path)

require 'toy'
require 'moneta'
require 'moneta/adapters/file'
require 'moneta/adapters/memory'

MemoryStore = Moneta::Builder.new do
  run Moneta::Adapters::Memory
end

class User
  include Toy::Store
  store MemoryStore
end

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = User.new
  end
end