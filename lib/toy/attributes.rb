# encoding: UTF-8
module Toy
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      attribute :id
    end

    module ClassMethods
      def define_attribute_methods
        attribute_method_suffix "", "=", "?"
        super(attributes.keys)
      end

      def attributes
        @attributes ||= {}
      end

      def attribute(key)
        key = key.to_sym
        attributes[key] = Attribute.new(self, key)
      end

      def attribute?(key)
        attributes.keys.include?(key.to_sym)
      end
    end

    module InstanceMethods
      def initialize(attrs={})
        write_attribute :id, Toy.next_id
        self.attributes = attrs
      end

      def attributes
        @attributes ||= {}.with_indifferent_access
      end

      def attributes=(attrs)
        return if attrs.nil?
        attrs.each { |key, value| write_attribute(key, value) }
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

      private
        def read_attribute(key)
          attributes[key]
        end
        alias :[] :read_attribute

        def write_attribute(key, value)
          attributes[key] = value
        end
        alias :[]= :write_attribute

        def attribute_method?(key)
          self.class.attribute?(key)
        end

        def attribute(key)
          read_attribute(key)
        end

        def attribute=(key, value)
          write_attribute(key, value)
        end

        def attribute?(key)
          read_attribute(key).present?
        end
    end
  end
end