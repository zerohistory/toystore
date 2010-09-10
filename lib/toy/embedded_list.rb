require 'toy/proxies/embedded_list'

module Toy
  class EmbeddedList
    include Toy::Collection

    def after_initialize
      create_accessors
    end

    private
      def create_accessors
        model.class_eval """
          def #{name}
            #{instance_variable} ||= self.class.#{list_method}[:#{name}].new_proxy(self)
          end

          def #{name}=(records)
            #{name}.replace(records)
          end

          def #{name.to_s.singularize}_attributes=(attrs)
            self.#{name} = attrs.map do |value|
              value = value.is_a?(Hash) ? value : value[1]
              #{type}.new(value)
            end
          end

          def #{name.to_s.singularize}_attributes
            #{name}.map(&:attributes)
          end
        """

        type.class_eval { attr_accessor :parent_reference }
      end

      def proxy_class
        Toy::Proxies::EmbeddedList
      end

      def list_method
        :embedded_lists
      end
  end
end