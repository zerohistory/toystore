module Toy
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      attribute :id, String
    end

    module ClassMethods
      def define_attribute_methods
        attribute_method_suffix "", "=", "?"
        super(attributes.keys)
      end

      def attributes
        @attributes ||= {}
      end

      def attribute(key, type)
        Attribute.new(self, key, type)
      end

      def attribute?(key)
        attributes.keys.include?(key.to_sym)
      end
    end

    module InstanceMethods
      def initialize(attrs={})
        @_new_record = true
        write_attribute :id, SimpleUUID::UUID.new.to_guid
        self.attributes = attrs
      end

      def id
        read_attribute(:id)
      end

      def attributes
        @attributes ||= {}.with_indifferent_access
      end

      def attributes=(attrs)
        return if attrs.nil?
        attrs.each do |key, value|
          if attribute_method?(key)
            write_attribute(key, value)
          elsif respond_to?("#{key}=")
            send("#{key}=", value)
          end
        end
      end

      def respond_to?(*args)
        self.class.define_attribute_methods
        super
      end

      def method_missing(method, *args, &block)
        if self.class.attribute_methods_generated?
          super
        else
          self.class.define_attribute_methods
          send(method, *args, &block)
        end
      end

      private
        def read_attribute(key)
          attribute_definition(key).read(attributes[key])
        end
        alias :[] :read_attribute

        def write_attribute(key, value)
          attributes[key] = attribute_definition(key).write(value)
        end
        alias :[]= :write_attribute

        def attribute_definition(key)
          self.class.attributes[key.to_sym] || raise("Attribute '#{key}' is not defined")
        end

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