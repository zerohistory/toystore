require 'pathname'
require 'forwardable'

root_path       = Pathname(__FILE__).dirname.join('..').expand_path
extensions_path = root_path.join('lib', 'toy', 'extensions')

require 'simple_uuid'
require 'active_model'
require 'active_support/json'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/string/inflections'

Dir[extensions_path + '**/*.rb'].each { |file| require(file) }

module Toy
  extend self
  extend Forwardable
  def_delegators ActiveSupport::JSON, :encode, :decode
end

require 'toy/exceptions'
require 'toy/connection'
require 'toy/attribute'
require 'toy/attributes'
require 'toy/callbacks'
require 'toy/dirty'
require 'toy/equality'
require 'toy/persistence'
require 'toy/store'
require 'toy/serialization'
require 'toy/timestamps'
require 'toy/validations'
require 'toy/querying'

require 'toy/collection'
require 'toy/embedded_list'
require 'toy/embedded_lists'
require 'toy/list'
require 'toy/lists'
require 'toy/reference'
require 'toy/references'

require 'toy/index'
require 'toy/indices'
require 'toy/identity/abstract_key_factory'
require 'toy/identity/uuid_key_factory'
require 'toy/identity'
require 'toy/logger'
