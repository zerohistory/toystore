module Toy
  class EmbeddedList
    attr_accessor :model, :name, :options

    def initialize(model, name, *args, &block)
      @model   = model
      @name    = name.to_sym
      @options = args.extract_options!
      @type    = args.shift

      model.embedded_lists[name] = self
      model.attribute(key, Array)
      create_accessors

      options[:extensions] = modularized_extensions(block, options[:extensions])
    end

    def type
      @type ||= name.to_s.classify.constantize
    end

    def key
      @key ||= :"#{name.to_s.singularize}_attributes"
    end

    def instance_variable
      @instance_variable ||= :"@_#{name}"
    end

    def extensions
      options[:extensions]
    end

    def new_proxy(owner)
      EmbeddedListProxy.new(self, owner)
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    class EmbeddedListProxy
      include Enumerable
      extend  Forwardable

      def_delegators :@list, :model, :name, :type, :key, :options

      def initialize(list, owner)
        @list, @owner = list, owner
        list.extensions.each { |extension| extend(extension) }
      end

      def proxy_owner
        @owner
      end

      def target
        @target ||= target_attrs.map { |attrs| type.load(attrs) }
      end
      alias :to_a :target

      def each
        target.each { |i| yield(i) }
      end

      def eql?(other)
        target == other
      end
      alias :== :eql?

      def include?(record)
        return false if record.nil?
        target.include?(record)
      end

      def push(record)
        assert_type(record)
        self.target_attrs = target_attrs + [record.attributes]
      end
      alias :<< :push

      def concat(*records)
        records = records.flatten
        records.map { |record| assert_type(record) }
        self.target_attrs = target_attrs + records.map { |record| record.attributes }
      end

      def reset
        @target = nil
      end

      def replace(records)
        reset
        self.target_attrs = records.map { |r| r.attributes }
      end

      def create(attrs={})
        record = type.new(attrs)
        if record.valid?
          record.initialize_from_database
          push(record)
          proxy_owner.save
          reset
        end
        record
      end

      def destroy(*args, &block)
        ids = block_given? ? target.select(&block).map(&:id) : args.flatten
        target_attrs.delete_if { |attrs| ids.include?(attrs['id']) }
        proxy_owner.save
        reset
      end

      private
        def assert_type(record)
          unless record.instance_of?(type)
            raise(ArgumentError, "#{type} expected, but was #{record.class}")
          end
        end

        def target_attrs
          proxy_owner.send(key)
        end

        def target_attrs=(value)
          proxy_owner.send(:"#{key}=", value)
        end

        def method_missing(method, *args, &block)
          target.send(method, *args, &block)
        end
    end

    private
      def create_accessors
        model.class_eval """
          def #{name}
            #{instance_variable} ||= self.class.embedded_lists[:#{name}].new_proxy(self)
          end

          def #{name}=(records)
            #{name}.replace(records)
          end
        """
      end

      def modularized_extensions(*extensions)
        extensions.flatten.compact.map do |extension|
          Proc === extension ? Module.new(&extension) : extension
        end
      end
  end
end