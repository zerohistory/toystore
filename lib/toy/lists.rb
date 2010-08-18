module Toy
  module Lists
    extend ActiveSupport::Concern

    module ClassMethods
      def lists
        @lists ||= {}
      end

      def list(name, type=nil)
        List.new(self, name, type)
      end
    end
  end
end