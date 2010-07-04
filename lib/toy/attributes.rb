module Toy
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    module ClassMethods
      def define_attribute_methods
        attribute_method_suffix "", "=", "?"
        super(attributes.keys)
      end

      def attribute(name)
        name = name.to_sym
        attributes[name] = Attribute.new(self, name)
      end

      def attributes
        @attributes ||= {}
      end

      def attribute?(name)
        attributes.keys.include?(name)
      end
    end

    module InstanceMethods
      def attributes
        @attributes ||= {}
      end

      def respond_to?(*args)
        self.class.define_attribute_methods
        super
      end

      def method_missing(method, *args, &block)
        if !self.class.attribute_methods_generated?
          self.class.define_attribute_methods
          send(method, *args, &block)
        else
          super
        end
      end

      protected
        def attribute_method?(name)
          self.class.attribute?(name)
        end

        def attribute(name)
          attributes[name]
        end

        def attribute=(name, value)
          attributes[name] = value
        end

        def attribute?(name)
          attribute(name).present?
        end
    end
  end
end