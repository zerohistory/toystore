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

    def equal?(other)
      if other.respond_to?(:proxy_respond_to?) && other.respond_to?(:target)
        other = other.target
      end
      super other
    end
  end
end