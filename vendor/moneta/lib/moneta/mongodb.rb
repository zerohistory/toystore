begin
  gem "mongo", ">= 1.0"
  require "mongo"
rescue LoadError
  puts "You need the mongo gem to use the MongoDB moneta store"
  exit
end

module Moneta
  class MongoDB
    include Defaults

    def initialize(options = {})
      options = {
        :host       => 'localhost',
        :port       => Mongo::Connection::DEFAULT_PORT,
        :db         => 'cache',
        :collection => 'cache'
      }.update(options)
      conn   = Mongo::Connection.new(options[:host], options[:port])
      @store = conn.db(options[:db]).collection(options[:collection])
    end

    def key?(key)
      !!self[key]
    end

    def [](key)
      doc = @store.find_one(:_id => key)
      doc = nil if doc && doc['expires'] && Time.now > doc['expires']
      doc && doc['value']
    end

    def []=(key, value)
      store(key, value)
    end

    def delete(key)
      value = self[key]
      @store.remove(:_id => key) if value
      value
    end

    def store(key, value, options = {})
      exp = options[:expires_in] ? (Time.now + options[:expires_in]) : nil
      @store.update({:_id => key }, {:_id => key, :value => value, :expires => exp}, :upsert => true)
    end

    def update_key(key, options = {})
      self.store(key, self[key], options)
    end

    def clear
      @store.remove
    end
  end
end

