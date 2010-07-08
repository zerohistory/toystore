begin
  require "memcached"
rescue
  puts "You need the memcached gem to use the Memcache moneta store"
  exit
end

module Moneta
  class Memcached
    include Defaults

    def initialize(*args)
      @store = ::Memcached.new(*args)
    end

    def key?(key)
      !self[key].nil?
    end

    alias has_key? key?

    def [](key)
      @store.get(key)
    rescue ::Memcached::NotFound
      nil
    end

    def []=(key, value)
      store(key, value)
    end

    def delete(key)
      value = self[key]
      @store.delete(key) if value
      value
    end

    def store(key, value, options = {})
      args = [key, value, options[:expires_in]].compact
      @store.set(*args)
    end

    def update_key(key, options = {})
      val = self[key]
      self.store(key, val, options)
    end

    def clear
      @store.flush
    end
  end
end
