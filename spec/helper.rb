$:.unshift(File.expand_path('../../lib', __FILE__))
require 'toy'
require 'spec'
require 'models'

require File.expand_path('../../vendor/moneta/lib/moneta/file', __FILE__)
require File.expand_path('../../vendor/moneta/lib/moneta/redis', __FILE__)
require File.expand_path('../../vendor/moneta/lib/moneta/mongodb', __FILE__)

def Model(name=nil, &block)
  klass = Class.new do
    include Toy::Store
    store Moneta::Redis.new

    if name
      class_eval "def self.name; '#{name}' end"
      class_eval "def self.to_s; '#{name}' end"
    end
  end
  klass.class_eval(&block) if block_given?
  klass
end