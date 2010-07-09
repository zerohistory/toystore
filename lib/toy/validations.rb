module Toy
  module Validations
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :validation
    end

    module InstanceMethods
      def valid?
        run_callbacks(:validation) { super }
      end

      def save
        valid? ? super : false
      end
    end
  end
end