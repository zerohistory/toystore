# encoding: UTF-8
require 'active_model'
require 'active_support/core_ext/object'

module Toy
  autoload :Attribute,    'toy/attribute'
  autoload :Attributes,   'toy/attributes'
  autoload :Persistence,  'toy/persistence'
  autoload :Store,        'toy/store'
  autoload :Version,      'toy/version'
end