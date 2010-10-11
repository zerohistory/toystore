module Toy
  module Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks :save, :create, :update, :destroy
    end

    module InstanceMethods
      def save(*)
        run_callbacks(:save) { super }
      end

      def destroy
        run_callbacks(:destroy) { super }
      end

      private

        def create
          run_callbacks(:create) { super }
        end

        def update
          run_callbacks(:update) { super }
        end
    end
  end
end