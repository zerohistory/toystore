# based on the redis-objects lock (http://github.com/nateware/redis-objects/blob/master/lib/redis/lock.rb)
module Toy
  class Lock
    extend Forwardable

    attr_reader :model, :name, :options
    def_delegator :model, :adapter

    def initialize(model, name, options={})
      options.assert_valid_keys(:timeout, :expiration, :start, :init)

      @model, @name, @options = model, name, options

      @options[:timeout] ||= 5
      @options[:init] = false if @options[:init].nil? # default :init to false

      constant_extension_name = model.adapter.name.to_s.classify

      if Toy::Locks.constants.include?(constant_extension_name)
        extend(Toy::Locks.const_get(constant_extension_name))
      end

      unless @options[:start] == 0 || @options[:init] === false
        set_expiration_if_not_exists(@options[:start])
      end
    end

    # Get the lock and execute the code block. Any other code that needs the lock
    # (on any server) will spin waiting for the lock up to the :timeout
    # that was specified when the lock was defined.
    def lock(&block)
      start         = Time.now
      acquired_lock = false
      expiration    = nil

      while Time.now - start < options[:timeout]
        expiration = generate_expiration
        # Use the expiration as the value of the lock.
        acquired_lock = set_expiration_if_not_exists(expiration)
        break if acquired_lock

        # Lock is being held.  Now check to see if it's expired (if we're using lock expiration).
        if !options[:expiration].nil?
          old_expiration = adapter[name].to_f

          if old_expiration < Time.now.to_f
            # If it's expired, use GETSET to update it.
            expiration = generate_expiration
            old_expiration = getset(expiration).to_f

            if old_expiration < Time.now.to_f
              acquired_lock = true
              break
            end
          end
        end

        sleep 0.1
      end

      raise(LockTimeout.new(name, options[:timeout])) unless acquired_lock

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

    def clear
      adapter.delete(name)
    end

    # This is not a true set if not exists and
    # should be overridden on a per adapter basis
    def set_expiration_if_not_exists(expiration)
      !adapter.key?(name).tap do |result|
        adapter.write(name, expiration) unless result
      end
    end

    # Returns old value and sets it to new value
    def getset(expiration)
      adapter.read(name).tap { adapter.write(name, expiration) }
    end

    def generate_expiration
      options[:expiration].nil? ? 1 : (Time.now + options[:expiration].to_f + 1).to_f
    end
  end
end
