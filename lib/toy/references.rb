module Toy
  module References
    extend ActiveSupport::Concern

    module ClassMethods
      def references
        @references ||= {}
      end

      def reference(name)
        Reference.new(self, name)
      end
    end
  end
end