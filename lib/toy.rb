require 'set'
require 'pathname'
require 'forwardable'
require 'digest/sha1'

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

  # Resets all tracking of things in memory
  def reset
    identity_map.clear
    plugins.clear
    models.clear
  end

  # Clears all the stores for all the models. Useful in specs/tests/etc.
  # Do not use in production, harty harr harr.
  def clear
    models.each do |model|
      if model.store.present?
        model.store.clear
        model.identity_map.clear
      end
    end
  end
end

require 'toy/exceptions'
require 'toy/connection'
require 'toy/attribute'
require 'toy/attributes'
require 'toy/callbacks'
require 'toy/dirty'
require 'toy/dolly'
require 'toy/equality'
require 'toy/inspect'
require 'toy/persistence'
require 'toy/mass_assignment_security'
require 'toy/plugins'
require 'toy/store'
require 'toy/serialization'
require 'toy/timestamps'
require 'toy/validations'
require 'toy/querying'
require 'toy/identity_map'

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
require 'toy/caching'
require 'toy/logger'
