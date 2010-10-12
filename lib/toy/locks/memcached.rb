require 'memcached'

module Toy
  module Locks
    module Memcached
      def set_expiration_if_not_exists(expiration)
        adapter.client.add(name, expiration)
        true
      rescue ::Memcached::NotStored
        false
      end

      def getset(expiration)
        super
      end
    end
  end
end