module Toy
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    module InstanceMethods
      def initialize(*)
        super
        # never register initial id assignment as a change
        @changed_attributes.delete('id')
      end

      def initialize_from_database(*)
        super.tap do
          @previously_changed = {}
          @changed_attributes.clear
        end
      end

      def reload(*)
        super.tap do
          @previously_changed.clear
          @changed_attributes.clear
        end
      end

      def save
        super.tap do
          @previously_changed = changes
          @changed_attributes.clear
        end
      end

      def write_attribute(name, value)
        name    = name.to_s
        current = read_attribute(name)
        attribute_will_change!(name) if current != value
        super
      end
    end
  end
end