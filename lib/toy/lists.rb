module Toy
  module Lists
    extend ActiveSupport::Concern

    module ClassMethods
      def lists
        @lists ||= {}
      end

      def list(name, options = {})
        List.new(self, name, options)
      end
    end
  end
end