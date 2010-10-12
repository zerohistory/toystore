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

      def run_callbacks(callback, &block)
        callback = :create if callback == :update && !persisted?

        embedded_records = self.class.embedded_lists.keys.inject([]) do |records, key|
          records += send(key).target
        end

        block = embedded_records.inject(block) do |chain, record|
          if record.class.respond_to?("_#{callback}_callbacks")
            lambda { record.run_callbacks(callback, &chain) }
          else
            chain
          end
        end
        super callback, &block
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