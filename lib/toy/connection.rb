module Toy
  module Connection
    def adapter(name=nil, client=nil)
      @adapter = Adapter[name].new(client) if !name.nil? && !client.nil?
      @adapter
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
  end
end