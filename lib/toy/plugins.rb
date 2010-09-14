module Toy
  def models
    @models ||= Set.new
  end

  def plugins
    @plugins ||= Set.new
  end

  def plugin(mod)
    Toy.models.each { |model| model.send(:include, mod) }
    plugins << mod
  end

  module Plugins
    extend ActiveSupport::Concern

    included do
      Toy.models << self
      Toy.plugins.each { |mod| include mod }
    end
  end
end