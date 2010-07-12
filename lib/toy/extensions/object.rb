module Toy
  module Extensions
    module Object
      module ClassMethods
        def to_store(value)
          value
        end

        def from_store(value)
          value
        end
      end

      module InstanceMethods
        def to_store
          self.class.to_store(self)
        end
      end
    end
  end
end

class Object
  extend Toy::Extensions::Object::ClassMethods
  include Toy::Extensions::Object::InstanceMethods
end