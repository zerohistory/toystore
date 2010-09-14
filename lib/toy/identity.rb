module Toy
  module Identity
    extend ActiveSupport::Concern

    included do
      key Toy.key_factory
    end

    module ClassMethods
      def key(name_or_factory = :uuid)
        @key_factory = case name_or_factory
        when :uuid
          UUIDKeyFactory.new
        else
          name_or_factory
        end
      end

      def next_key(object = nil)
        @key_factory.next_key(object).tap do |key|
          raise "Keys may not be nil" if key.nil?
        end
      end
    end
  end
end
