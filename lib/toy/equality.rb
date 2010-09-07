module Toy
  module Equality
    def eql?(other)
      return true if self.class.eql?(other.class) && id == other.id
      return true if other.respond_to?(:target) &&
                     self.class.eql?(other.target.class) &&
                     id == other.target.id
      false
    end
    alias :== :eql?
  end
end