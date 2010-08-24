module Toy
  module Connection
    def store
      @@store
    end
    
    def store=(store)
      @@store = store
    end
    
    def logger
      return @@logger if @@logger
      @@logger = init_default_logger
    end
    
    def logger=(logger)
      @@logger = logger
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