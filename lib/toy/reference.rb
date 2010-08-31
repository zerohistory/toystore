module Toy
  class Reference
    attr_accessor :model, :name, :options

    def initialize(model, name, *args)
      @model   = model
      @name    = name.to_sym
      @options = args.extract_options!
      @type    = args.shift
      
      model.references[name] = self
      model.attribute(key, String)
      create_accessors
    end

    def type
      @type ||= name.to_s.classify.constantize
    end

    def key
      @key ||= :"#{name.to_s.singularize}_id"
    end

    def instance_variable
      @instance_variable ||= :"@_#{name}"
    end

    def new_proxy(owner)
      ReferenceProxy.new(self, owner)
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    class ReferenceProxy
      extend Forwardable

      def_delegators :@reference, :model, :name, :type, :key

      def_delegators :target, :nil?, :present?, :blank?

      def initialize(reference, owner)
        @reference, @owner = reference, owner
      end

      def proxy_owner
        @owner
      end

      def target
        return nil if target_id.blank?
        @target ||= type.get(target_id)
      end

      def eql?(other)
        target == other
      end
      alias :== :eql?

      def reset
        @target = nil
      end

      def replace(record)
        if record.nil?
          reset
          self.target_id = nil
        else
          assert_type(record)
          reset
          self.target_id = record.id
        end
      end

      def create(attrs={})
        type.create(attrs).tap do |record|
          if record.persisted?
            self.target_id = record.id
            proxy_owner.save
            reset
          end
        end
      end

      def build(attrs={})
        type.new(attrs).tap do |record|
          self.target_id = record.id
          reset
        end
      end

      private
        def assert_type(record)
          unless record.instance_of?(type)
            raise(ArgumentError, "#{type} expected, but was #{record.class}")
          end
        end

        def target_id
          proxy_owner.send(key)
        end

        def target_id=(value)
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
            #{instance_variable} ||= self.class.references[:#{name}].new_proxy(self)
          end

          def #{name}=(record)
            #{name}.replace(record)
          end

          def #{name}?
            #{name}.present?
          end
        """
      end
  end
end