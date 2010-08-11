module Toy
  module Lists
    extend ActiveSupport::Concern

    included do
      include Module.new.tap { |mod| const_set('ListAccessors', mod) }
    end

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