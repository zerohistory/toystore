module Toy
  class Attribute
    attr_reader :model, :name, :type, :options

    def initialize(model, name, type, options={})
      options.assert_valid_keys(:default, :embedded_list, :virtual, :abbr)

      @model, @name, @type, @options = model, name.to_sym, type, options
      @virtual = options.fetch(:virtual, false)

      if abbr?
        options[:abbr] = abbr.to_sym
        model.alias_attribute(abbr, name)
      end

      model.attributes[name.to_s] = self
    end

    def from_store(value)
      value = default if default? && value.nil?
      type.from_store(value, self)
    end

    def to_store(value)
      value = default if default? && value.nil?
      type.to_store(value, self)
    end

    def default
      if options.key?(:default)
        options[:default].respond_to?(:call) ? options[:default].call : options[:default]
      else
        type.respond_to?(:store_default) ? type.store_default : nil
      end
    end

    def default?
      options.key?(:default) || type.respond_to?(:store_default)
    end

    def virtual?
      @virtual
    end

    def persisted?
      !virtual?
    end

    def abbr?
      options.key?(:abbr)
    end

    def abbr
      options[:abbr]
    end

    def store_key
      (abbr? ? abbr : name).to_s
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