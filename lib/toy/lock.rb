# based on the redis-objects lock (http://github.com/nateware/redis-objects/blob/master/lib/redis/lock.rb)
module Toy
  class Lock
    attr_reader :model, :store, :name, :options

    def initialize(model, name, options={})
      options.assert_valid_keys(:timeout, :expiration, :start, :init, :store, :store_options)
      @model, @name, @options = model, name, options
      if options[:store]
        options[:store_options] ||= {}
        @store = Toy.build_store options[:store], options[:store_options]
      else
        @store = model.store
      end
      @options[:timeout] ||= 5
      @options[:init] = false if @options[:init].nil? # default :init to false
      setnx(@options[:start]) unless @options[:start] == 0 || @options[:init] === false
    end

    def clear
      store.delete(name)
    end

    # Get the lock and execute the code block. Any other code that needs the lock
    # (on any server) will spin waiting for the lock up to the :timeout
    # that was specified when the lock was defined.
    def lock(&block)
      start = Time.now
      gotit = false
      expiration = nil
      while Time.now - start < options[:timeout]
        expiration = generate_expiration
        # Use the expiration as the value of the lock.
        gotit = setnx(expiration)
        break if gotit

        # Lock is being held.  Now check to see if it's expired (if we're using lock expiration).
        if !options[:expiration].nil?
          old_expiration = store[name].to_f

          if old_expiration < Time.now.to_f
            # If it's expired, use GETSET to update it.
            expiration = generate_expiration
            old_expiration = getset(expiration).to_f

            if old_expiration < Time.now.to_f
              gotit = true
              break
            end
          end
        end

        sleep 0.1
      end
      raise LockTimeout.new(name, options[:timeout]) unless gotit
      begin
        yield
      ensure
        # We need to be careful when cleaning up the lock key.  If we took a really long
        # time for some reason, and the lock expired, someone else may have it, and
        # it's not safe for us to remove it.  Check how much time has passed since we
        # wrote the lock key and only delete it if it hasn't expired (or we're not using
        # lock expiration)
        if options[:expiration].nil? || expiration > Time.now.to_f
          clear
        end
      end
    end

    # This is not a true set if not exists
    def setnx(expiration)
      if store[name]
        return false
      else
        store[name] = expiration
        return true
      end
    end

    def getset(expiration)
      old_value = store[name]
      store[name] = expiration
      return old_value
    end

    def generate_expiration
      options[:expiration].nil? ? 1 : (Time.now + options[:expiration].to_f + 1).to_f
    end
  end
end
