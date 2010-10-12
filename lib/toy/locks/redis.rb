require 'redis'

module Toy
  module Locks
    module Redis
      def set_expiration_if_not_exists(expiration)
        adapter.client.setnx(name.to_s, expiration)
      end

      def getset(expiration)
        adapter.client.getset(name.to_s, expiration)
      end
    end
  end
end