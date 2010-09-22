module Toy
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    module InstanceMethods
      def initialize(*)
        super
        if new_record?
          # never register initial id assignment as a change
          @changed_attributes.delete('id')
        else
          @previously_changed = {}
          @changed_attributes.clear if @changed_attributes
        end
      end

      def initialize_copy(*)
        super.tap do
          @previously_changed = {}
          @changed_attributes = {}
        end
      end

      def reload
        super.tap do
          @previously_changed.clear if @previously_changed
          @changed_attributes.clear if @changed_attributes
        end
      end

      def save(*)
        super.tap do
          @previously_changed = changes
          @changed_attributes.clear if @changed_attributes
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