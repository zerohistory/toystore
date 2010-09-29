require 'memcached'

module Toy
  module Locks
    module Memcache
      def setnx(expiration)
        memcache.add(name.to_s, expiration)
        return true
      rescue Memcached::NotStored
        return false
      end

      private
        def memcache
          # Moneta does not expose anything
          @memcache ||= store.instance_variable_get("@adapter").instance_variable_get("@cache")
        end
    end
  end
end