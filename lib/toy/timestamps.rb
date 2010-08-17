module Toy
  module Timestamps
    extend ActiveSupport::Concern

    module ClassMethods
      def timestamps
        attribute(:created_at, Time)
        attribute(:updated_at, Time)

        before_create do |record|
          now = Time.now
          record.created_at = now unless created_at?
          record.updated_at = now
        end

        before_update do |record|
          record.updated_at = Time.now
        end
      end
    end
  end
end