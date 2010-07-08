begin
  gem 'redis', '>= 2.0'
  require 'redis'
rescue LoadError
  puts "You need the redis gem to use the Redis store"
  exit
end

module Moneta
  class Redis
    include Defaults

    def initialize(options = {})
      @store = ::Redis.new(options)
    end

    def key?(key)
      !@store[key].nil?
    end

    alias has_key? key?

    def [](key)
      @store.get(key)
    end

    def []=(key, value)
      store(key, value)
    end

    def delete(key)
      value = @store[key]
      @store.del(key) if value
      value
    end

    def store(key, value, options = {})
      @store.set(key, value)
      @store.expire(key, options[:expires_in])
    end

    def update_key(key, options = {})
      val = @store[key]
      self.store(key, val, options)
    end

    def clear
      @store.flushdb
    end
  end
end
