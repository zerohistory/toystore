module Toy
  module Locks
    extend ActiveSupport::Concern

    module ClassMethods
      def locks
        @locks ||= {}
      end

      def lock(name, options={})
        global = options.delete(:global)
        locks[name] = options
        lock_name = "#{name}_lock"
        if global
          self.instance_eval """
            def #{lock_name}
              @#{lock_name} ||= Toy::Lock.new(self, lock_key(:#{name}), locks[:#{name}])
            end
          """
          self.class_eval """
            def #{name}_lock
              self.class.#{name}_lock
            end
          """
        else
          self.class_eval """
            def #{name}_lock
              @#{lock_name} ||= Toy::Lock.new(self, lock_key(:#{name}), self.class.locks[:#{name}])
            end
          """
        end
      end

      def obtain_lock(name, id, &block)
        raise Toy::UndefinedLock.new(self, name) unless locks[name]
        raise ArgumentError, "Missing block to #{self.name}.obtain_lock" unless block_given?
        Toy::Lock.new(self, lock_key(name, id), locks[name]).lock(&block)
      end

      def clear_lock(name, id)
        store.delete(lock_key(name, id))
      end

      def lock_key(name, id=nil)
        [self.name, id, "#{name}_lock"].compact.join(':')
      end
    end

    module InstanceMethods
      def lock_key(name)
        self.class.lock_key(name, self.id)
      end
    end
  end
end