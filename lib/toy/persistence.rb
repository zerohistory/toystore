module Toy
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def store(name=nil, client=nil, options=nil)
        assert_client(name, client)
        @store = Adapter[name].new(client, options) if !name.nil? && !client.nil?
        assert_store(name, client, 'store')
        @store
      end

      def has_store?
        !@store.nil?
      end

      def cache(name=nil, client=nil)
        assert_client(name, client)
        @cache = Adapter[name].new(client) if !name.nil? && !client.nil?
        assert_store(name, client, 'cache')
        @cache
      end

      def has_cache?
        !@cache.nil?
      end

      def namespace(new_namespace=nil)
        if new_namespace.nil?
          @namespace ||= self.name
        else
          @namespace = new_namespace
        end

        @namespace
      end

      def store_key(id)
        [namespace, id].join(':')
      end

      def create(attrs={})
        new(attrs).tap { |doc| doc.save }
      end

      def delete(*ids)
        ids.each { |id| get(id).try(:delete) }
      end

      def destroy(*ids)
        ids.each { |id| get(id).try(:destroy) }
      end

      private
        def assert_client(name, client)
          raise(ArgumentError, 'Client is required') if !name.nil? && client.nil?
        end

        def assert_store(name, client, which)
          raise(StandardError, "No #{which} has been set") if name.nil? && client.nil? && !send(:"has_#{which}?")
        end
    end

    module InstanceMethods
      def store
        self.class.store
      end

      def cache
        self.class.cache
      end

      def store_key
        self.class.store_key(id)
      end

      def new_record?
        @_new_record == true
      end

      def destroyed?
        @_destroyed == true
      end

      def persisted?
        !new_record? && !destroyed?
      end

      def save(*)
        new_record? ? create : update
      end

      def update_attributes(attrs)
        self.attributes = attrs
        save
      end

      def destroy
        delete
      end

      def delete
        key = store_key
        @_destroyed = true
        logger.debug("ToyStore DEL #{key.inspect}")
        store.delete(key)
      end

      private
        def create
          persist!
        end

        def update
          persist!
        end

        def persist
          @_new_record = false
        end

        def persist!
          key, attrs = store_key, persisted_attributes

          if self.class.has_cache?
            cache.write(key, attrs)
            log_operation('WTS', cache, key, attrs)
          end

          store.write(key, attrs)
          log_operation('SET', store, key, attrs)
          persist
          each_embedded_object(&:persist)
          true
        end
    end
  end
end