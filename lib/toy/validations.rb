module Toy
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :validation
    end

    module ClassMethods
      def validates_embedded(*names)
        validates_each(*names) do |record, name, value|
          record.errors.add(name, 'is invalid') unless value.compact.all?(&:valid?)
        end
      end

      def create!(attrs={})
        new(attrs).tap { |doc| doc.save! }
      end
    end

    module InstanceMethods
      def valid?
        run_callbacks(:validation) { super }
      end

      def save(options={})
        options.assert_valid_keys(:validate)
        !options.fetch(:validate, true) || valid? ? super : false
      end

      def save!
        save || raise(RecordInvalidError.new(self))
      end
    end
  end
end