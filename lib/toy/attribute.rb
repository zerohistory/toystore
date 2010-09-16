module Toy
  class Attribute
    attr_reader :model, :name, :type, :options

    def initialize(model, name, type, options={})
      options.assert_valid_keys(:default, :embedded_list, :virtual)
      @model, @name, @type, @options = model, name.to_sym, type, options
      @virtual = options.fetch(:virtual, false)
      model.attributes[name.to_s] = self
    end

    def read(value)
      value = default if default? && value.nil?
      type.from_store(value, self)
    end

    def write(value)
      value = default if default? && value.nil?
      type.to_store(value, self)
    end

    def default
      if default?
        options[:default].respond_to?(:call) ? options[:default].call : options[:default]
      end
    end

    def default?
      options.key?(:default)
    end

    def virtual?
      @virtual
    end

    def persisted?
      !virtual?
    end

    # Stores reference to related embedded list
    def embedded_list
      options[:embedded_list]
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?
  end
end