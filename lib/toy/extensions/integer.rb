module Toy
  module Extensions
    module Integer
      def to_store(value)
        value_to_i = value.to_i
        if value_to_i == 0 && value != value_to_i
          value.to_s =~ /^(0x|0b)?0+/ ? 0 : nil
        else
          value_to_i
        end
      end
    end
  end
end

class Integer
  extend Toy::Extensions::Integer
end