require 'set'

module Toy
  def models
    @models ||= Set.new
  end

  def plugin(mod)
    Toy.models.each do |model|
      model.send(:include, mod)
    end
  end

  module Plugins
    extend ActiveSupport::Concern

    included { Toy.models << self }
  end
end