begin
  require "localmemcache"
rescue LoadError
  puts "You need the localmemcache gem to use the LMC moneta store"
  exit
end

module Moneta
  class Expiration
    def initialize(hash)
      @hash = hash
    end

    def [](key)         @hash["#{key}__!__expiration"]          end
    def []=(key, value) @hash["#{key}__!__expiration"] = value  end

    def delete(key)
      key = "#{key}__!__expiration"
      value = @hash[key]
      @hash.delete(key)
      value
    end
  end

  class LMC
    include Defaults

    module Implementation
      def initialize(options = {})
        @store = LocalMemCache.new(:filename => options[:filename])
        @expiration = Expiration.new(@store)
      end

      def [](key)         @store[key]          end
      def []=(key, value) @store[key] = value  end
      def clear()         @store.clear         end

      def key?(key)
        @store.keys.include?(key)
      end

      def delete(key)
        value = @store[key]
        @store.delete(key)
        value
      end
    end
    include Implementation
    include StringExpires

  end
end