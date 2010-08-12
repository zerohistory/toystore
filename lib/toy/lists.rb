module Toy
  module Lists
    extend ActiveSupport::Concern

    included do
      unless const_defined?('ListAccessors')
        const_set('ListAccessors', Module.new)
        include const_get('ListAccessors')
      end
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