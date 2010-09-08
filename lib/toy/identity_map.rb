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
        attrs = normalize_load_attributes(attrs)
        return nil if attrs.nil?

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
      each_embedded_object { |object| object.add_to_identity_map }
    end

    def remove_from_identity_map
      identity_map.delete(store_key)
      each_embedded_object { |object| object.remove_from_identity_map }
    end

    private
      def has_embedded_objects?
        self.class.embedded_lists.any?
      end

      def each_embedded_object(&block)
        if has_embedded_objects?
          self.class.embedded_lists.keys.inject([]) do |objects, name|
            objects.concat(send(name).to_a.compact)
          end.each { |object| block.call(object) }
        end
      end
  end
end