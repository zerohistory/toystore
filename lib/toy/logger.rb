module Toy
  module Logger
    extend ActiveSupport::Concern

    module ClassMethods
      def logger
        Toy.logger
      end

      def log_operation(operation, adapter, key, value)
        logger.debug("ToyStore #{operation} :#{adapter.name} #{key.inspect}")
        logger.debug("  #{value.inspect}")
      end
    end

    module InstanceMethods
      def logger
        Toy.logger
      end

      def log_operation(*args)
        self.class.log_operation(*args)
      end
    end
  end
end