# encoding: UTF-8
require 'active_model'
require 'active_support/core_ext/object'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/inheritable_attributes'

$:.unshift('/Users/jnunemaker/dev/projects/moneta/lib')
require 'moneta'

module Toy
  autoload :Attribute,    'toy/attribute'
  autoload :Attributes,   'toy/attributes'
  autoload :Persistence,  'toy/persistence'
  autoload :Store,        'toy/store'
  autoload :Version,      'toy/version'
end