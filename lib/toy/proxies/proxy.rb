module Toy
  module Proxies
    class Proxy
      include Enumerable
      extend  Forwardable

      def_delegator :@list, :type,    :proxy_class
      def_delegator :@list, :key,     :proxy_key
      def_delegator :@list, :options, :proxy_options

      def initialize(list, owner)
        @list, @owner = list, owner
        list.extensions.each { |extension| extend(extension) }
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