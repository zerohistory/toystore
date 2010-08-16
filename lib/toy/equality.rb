module Toy
  module Equality
    def eql?(other)
      self.class.eql?(other.class) && id == other.id
    end
    alias :== :eql?
  end
end