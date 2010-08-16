module Toy
  module Lists
    extend ActiveSupport::Concern

    module ClassMethods
      def lists
        @lists ||= {}
      end

      def list(name)
        List.new(self, name)
      end
    end
  end
end