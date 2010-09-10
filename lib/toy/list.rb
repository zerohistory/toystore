require 'toy/proxies/list'

module Toy
  class List
    include Toy::Collection

    def after_initialize
      model.attribute(key, Array)
      create_accessors
    end

    def key
      @key ||= :"#{name.to_s.singularize}_ids"
    end

    private
      def proxy_class
        Toy::Proxies::List
      end

      def list_method
        :lists
      end

      def create_accessors
        model.class_eval """
          def #{name}
            #{instance_variable} ||= self.class.#{list_method}[:#{name}].new_proxy(self)
          end

          def #{name}=(records)
            #{name}.replace(records)
          end
        """

        if options[:dependent]
          model.class_eval """
            after_destroy :destroy_#{name}
            def destroy_#{name}
              #{name}.each { |o| o.destroy }
            end
          """
        end
      end
  end
end