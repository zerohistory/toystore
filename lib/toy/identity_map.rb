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

      def identity_map_key(id)
        "#{model_name.singular}:#{id}"
      end

      def get(id)
        identity_map[identity_map_key(id)] || super
      end

      def load(attrs)
        return nil if attrs.nil?
        attrs = Toy.decode(attrs) if attrs.is_a?(String)

        if instance = identity_map[identity_map_key(attrs['id'])]
          instance
        else
          super.tap { |doc| doc.add_to_identity_map }
        end
      end
    end

    def identity_map_key
      self.class.identity_map_key(id)
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
      identity_map[identity_map_key] = self
    end

    def remove_from_identity_map
      identity_map.delete(identity_map_key)
    end
  end
end