require 'bundler/setup'
require 'pathname'

root_path   = Pathname(__FILE__).dirname.join('..').expand_path
lib_path    = root_path.join('lib')

$:.unshift(lib_path)

require 'toy'

Adapter.define(:memory) do
  def read(key)
    deserialize(client[key_for(key)])
  end

  def write(key, value)
    client[key_for(key)] = serialize(value)
  end

  def delete(key)
    client.delete(key_for(key))
  end

  def clear
    client.clear
  end
end

class User
  include Toy::Store
  adapter :memory, {}
end

class LintTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = User.new
  end
end