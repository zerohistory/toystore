module Toy
  class List
    attr_accessor :model, :name

    def initialize(model, name, type=nil)
      @model, @name, @type = model, name.to_sym, type
      model.lists[name] = self
      model.attribute(key, Array)
      create_accessors
    end

    def type
      @type ||= name.to_s.classify.constantize
    end

    def key
      @key ||= :"#{name.to_s.singularize}_ids"
    end

    def instance_variable
      @instance_variable ||= :"@_#{name}"
    end

    def new_proxy(owner)
      ListProxy.new(self, owner)
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    class ListProxy
      include Enumerable
      extend  Forwardable

      def_delegators :@list, :model, :name, :type, :key

      def initialize(list, owner)
        @list, @owner = list, owner
      end

      def proxy_owner
        @owner
      end

      def target
        return [] if target_ids.blank?
        @target ||= type.get_multi(target_ids)
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
        target_ids.include?(record.id)
      end

      def push(record)
        assert_type(record)
        self.target_ids = target_ids + [record.id]
      end
      alias :<< :push

      def concat(*records)
        records = records.flatten
        records.map { |record| assert_type(record) }
        self.target_ids = target_ids + records.map { |i| i.id }
      end

      def reset
        @target = nil
      end

      def replace(records)
        reset
        self.target_ids = records.map { |i| i.id }
      end

      def create(attrs={})
        type.create(attrs).tap do |record|
          if record.persisted?
            push(record)
            proxy_owner.save
            reset
          end
        end
      end

      private
        def assert_type(record)
          unless record.instance_of?(type)
            raise(ArgumentError, "#{type} expected, but was #{record.class}")
          end
        end

        def target_ids
          proxy_owner.send(key)
        end

        def target_ids=(value)
          proxy_owner.send("#{key}=", value)
        end

        def method_missing(method, *args, &block)
          target.send(method, *args, &block)
        end
    end

    private
      def create_accessors
        model.class_eval """
          def #{name}
            #{instance_variable} ||= self.class.lists[:#{name}].new_proxy(self)
          end

          def #{name}=(records)
            #{name}.replace(records)
          end
        """
      end
  end
end