module Toy
  class Index
    attr_accessor :model, :name

    def initialize(model, name)
      @model, @name = model, name.to_sym
      raise(ArgumentError, "No attribute #{name} for index") unless model.attribute?(name)

      model.indices[name] = self
      model.send(:include, IndexCallbacks)
      create_finders
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        model == other.model &&
        name  == other.name
    end
    alias :== :eql?

    def key(value)
      sha_value = Digest::SHA1.hexdigest(Array.wrap(value).sort.join('')) # sorted for predictability
      [model.name, name, sha_value].join(':')
    end

    module IndexCallbacks
      extend ActiveSupport::Concern

      included do
        after_create  :index_create
        after_update  :index_update
        after_destroy :index_destroy
      end

      def index_create
        indices.each_key do |name|
          create_index(name, send(name), id)
        end
      end

      def index_update
        indices.each_key do |name|
          if send(:"#{name}_changed?")
            destroy_index(name, send(:"#{name}_was"), id)
            create_index(name, send(name), id)
          end
        end
      end

      def index_destroy
        indices.each_key do |name|
          destroy_index(name, send(name), id)
        end
      end
    end

    private
      def create_finders
        model.class_eval """
          def self.first_by_#{name}(value)
            get(get_index(:#{name}, value)[0])
          end

          def self.first_or_new_by_#{name}(value)
            first_by_#{name}(value) || new(:#{name} => value)
          end

          def self.first_or_create_by_#{name}(value)
            first_by_#{name}(value) || create(:#{name} => value)
          end
        """
      end
  end
end