module Toy
  def self.identity_map
    Thread.current[:toystore_identity_map] ||= {}
  end

  module IdentityMap
    extend ActiveSupport::Concern

    module ClassMethods
      def identity_map
        Toy.identity_map
      end

      def get(id)
        identity_map[store_key(id)] || super
      end

      def load(attrs)
        return nil if attrs.nil?
        attrs = Toy.decode(attrs) if attrs.is_a?(String)

        if instance = identity_map[store_key(attrs['id'])]
          instance
        else
          super.tap { |doc| doc.add_to_identity_map }
        end
      end
    end

    def identity_map
      Toy.identity_map
    end

    def save(*)
      super.tap do |result|
        add_to_identity_map if result
      end
    end

    def delete(*)
      super.tap { remove_from_identity_map }
    end

    def add_to_identity_map
      identity_map[store_key] = self
      embedded_objects.each { |o| o.add_to_identity_map } if has_embedded_objects?
    end

    def remove_from_identity_map
      identity_map.delete(store_key)
      embedded_objects.each { |o| o.remove_from_identity_map } if has_embedded_objects?
    end

    private
      def has_embedded_objects?
        self.class.embedded_lists.any?
      end

      def embedded_objects
        self.class.embedded_lists.keys.inject([]) do |objects, name|
          objects.concat(send(name).to_a.compact)
        end
      end
  end
end