module Toy
  module References
    extend ActiveSupport::Concern

    module ClassMethods
      def references
        @references ||= {}
      end

      def reference(name, type=nil)
        Reference.new(self, name, type)
      end
    end
  end
end