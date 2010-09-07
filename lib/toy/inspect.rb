module Toy
  module Inspect
    extend ActiveSupport::Concern

    def inspect
      attributes_as_nice_string = self.class.attributes.keys.map(&:to_s).sort.map do |name|
        "#{name}: #{read_attribute(name).inspect}"
      end.join(", ")
      "#<#{self.class}:#{object_id} #{attributes_as_nice_string}>"
    end
  end
end