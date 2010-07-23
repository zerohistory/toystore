require 'forwardable'
require 'simple_uuid'
require 'active_model'
require 'active_support/json'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/inheritable_attributes'
require 'active_support/core_ext/string/conversions'
require 'active_support/core_ext/string/inflections'

require File.expand_path('../../vendor/moneta/lib/moneta', __FILE__)

module Toy
  extend Forwardable

  autoload :RecordInvalidError,    'toy/exceptions'

  autoload :Attribute,     'toy/attribute'
  autoload :Attributes,    'toy/attributes'
  autoload :Callbacks,     'toy/callbacks'
  autoload :Dirty,         'toy/dirty'
  autoload :Persistence,   'toy/persistence'
  autoload :Store,         'toy/store'
  autoload :Serialization, 'toy/serialization'
  autoload :Validations,   'toy/validations'
  autoload :Querying,      'toy/querying'
  autoload :List,          'toy/list'
  autoload :Lists,         'toy/lists'
  autoload :Version,       'toy/version'

  def_delegators ActiveSupport::JSON, :encode, :decode

  extend self
end

Dir[File.join(File.dirname(__FILE__), 'toy', 'extensions', '*.rb')].each do |extension|
  require extension
end