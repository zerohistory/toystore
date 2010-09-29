require 'redis'

module Toy
  module Locks
    module Redis
      def setnx(expiration)
        redis.setnx(name.to_s, expiration)
      end

      def getset(expiration)
        redis.getset(name.to_s, expiration)
      end

      private
        def redis
          # Moneta does not expose anything
          @redis ||= store.instance_variable_get("@adapter").instance_variable_get("@cache")
        end
    end
  end
end