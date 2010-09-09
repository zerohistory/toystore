module Toy
  module Collection
    extend ActiveSupport::Concern

    included do
      attr_accessor :model, :name, :options
    end

    def initialize(model, name, *args, &block)
      @model   = model
      @name    = name.to_sym
      @options = args.extract_options!
      @type    = args.shift

      model.send(list_method)[name] = self

      options[:extensions] = modularized_extensions(block, options[:extensions])
    end

    def type
      @type ||= name.to_s.classify.constantize
    end

    def instance_variable
      @instance_variable ||= :"@_#{name}"
    end

    def new_proxy(owner)
      proxy_class.new(self, owner)
    end

    def extensions
      options[:extensions]
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

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

    private
      def proxy_class
        raise('Not Implemented')
      end

      def modularized_extensions(*extensions)
        extensions.flatten.compact.map do |extension|
          Proc === extension ? Module.new(&extension) : extension
        end
      end
  end
end