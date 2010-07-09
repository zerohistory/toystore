# encoding: UTF-8
require 'active_model'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/inheritable_attributes'

require File.expand_path('../../vendor/moneta/lib/moneta', __FILE__)
require 'uuid'

module Toy
  autoload :Attribute,    'toy/attribute'
  autoload :Attributes,   'toy/attributes'
  autoload :Dirty,        'toy/dirty'
  autoload :Persistence,  'toy/persistence'
  autoload :Store,        'toy/store'
  autoload :Validations,  'toy/validations'
  autoload :Version,      'toy/version'

  # Not ideal, we'll need to have id factories for each store
  # as some stores support incr so we can have integer ids
  # but others do not and will need to use uuids
  def uuid
    @uuid ||= UUID.new
  end

  def next_id
    uuid.generate
  end

  extend self
end