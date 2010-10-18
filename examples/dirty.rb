require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'toy'
require 'adapter/memory'

class User
  include Toy::Store
  adapter :memory, {}
  attribute :name, String
end

user = User.new
user.name = 'John'
puts user.name_changed?
puts user.changed?.inspect
puts user.changed.inspect
puts user.changes.inspect
puts

user.save # clears changes
puts user.name_changed?
puts user.changed?.inspect
puts user.changed.inspect
puts user.changes.inspect
