module Toy
  module Proxies
    class Proxy
      include Enumerable
      extend  Forwardable

      def_delegator :@list, :type,    :proxy_class
      def_delegator :@list, :key,     :proxy_key
      def_delegator :@list, :options, :proxy_options

      alias :proxy_respond_to? :respond_to?
      alias :proxy_extend :extend

      instance_methods.each { |m| undef_method m unless m.to_s =~ /^(?:nil\?|send|object_id|to_a)$|^__|proxy_/ }

      def initialize(list, owner)
        @list, @owner = list, owner
        list.extensions.each { |extension| proxy_extend(extension) }
      end

      def proxy_owner
        @owner
      end

      def each
        target.each { |i| yield(i) }
      end

      def eql?(other)
        target == other
      end
      alias :== :eql?

      def target
        @target ||= find_target
      end
      alias :to_a :target

      def assert_type(record)
        unless record.is_a?(proxy_class)
          raise(ArgumentError, "#{proxy_class} expected, but was #{record.class}")
        end
      end

      def respond_to?(*args)
        proxy_respond_to?(*args) || target.respond_to?(*args)
      end

      private
        def find_target
          raise('Not Implemented')
        end

        def method_missing(method, *args, &block)
          target.send(method, *args, &block)
        end
    end
  end
end