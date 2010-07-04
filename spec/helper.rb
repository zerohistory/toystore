$:.unshift(File.expand_path('../../lib', __FILE__))
require 'toy'
require 'spec'
require 'models'

def Model(name=nil, &block)
  klass = Class.new do
    include Toy::Store
    if name
      class_eval "def self.name; '#{name}' end"
      class_eval "def self.to_s; '#{name}' end"
    end
  end
  klass.class_eval(&block) if block_given?
  klass
end