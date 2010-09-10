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
      after_initialize
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