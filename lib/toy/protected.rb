module Toy
  module Protected
    extend ActiveSupport::Concern

    module ClassMethods
      def attr_protected(*attrs)
        raise AccessibleOrProtected.new(name) if try(:accessible_attributes?)
        @protected_attributes = Set.new(attrs) + protected_attributes
      end

      def protected_attributes
        @protected_attributes || []
      end

      def protected_attributes?
        !protected_attributes.empty?
      end
    end

    module InstanceMethods
      def initialize(attrs={})
        super(filter_protected_attrs(attrs))
      end

      def update_attributes(attrs={})
        super(filter_protected_attrs(attrs))
      end

      def protected_attributes
        self.class.protected_attributes
      end

      protected
        def filter_protected_attrs(attrs)
          return attrs if protected_attributes.blank? || attrs.blank?
          attrs.dup.delete_if { |key, val| protected_attributes.include?(key.to_sym) }
        end
    end
  end
end