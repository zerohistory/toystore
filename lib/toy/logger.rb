module Toy
  module Logger
    extend ActiveSupport::Concern

    module ClassMethods
      def logger
        Toy.logger
      end
    end

    module InstanceMethods
      def logger
        Toy.logger
      end
    end
  end
end