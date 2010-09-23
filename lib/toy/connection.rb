module Toy
  module Connection
    def store
      @@store if defined?(@@store)
    end

    def store(new_store=nil, *args)
      @store = build_store(new_store, *args) unless new_store.nil?
      @store
    end

    def logger
      @@logger ||= init_default_logger
    end

    def logger=(logger)
      @@logger = logger
    end

    def key_factory=(key_factory)
      @@key_factory = key_factory
    end

    def key_factory
      @@key_factory ||= Toy::Identity::UUIDKeyFactory.new
    end

    def init_default_logger
      if Object.const_defined?("RAILS_DEFAULT_LOGGER")
        @@logger = Object.const_get("RAILS_DEFAULT_LOGGER")
      else
        require 'logger'
        @@logger = ::Logger.new(STDOUT)
      end
    end

    def build_store(store, *args)
      return store if store.is_a?(Moneta::Builder)
      adapter = Moneta::Adapters.const_get(store.to_s.capitalize)
      Moneta::Builder.new { run(adapter, *args) }
    end
  end
end