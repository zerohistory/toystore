module Toy
  module Dolly
    extend ActiveSupport::Concern

    def initialize_copy(other)
      @_new_record = true
      @_destroyed  = false
      @attributes = {}.with_indifferent_access

      self.class.embedded_lists.each do |name, list|
        instance_variable_set(list.instance_variable, nil)
      end

      other.attributes.except('id').each do |key, value|
        value = if self.class.embedded_list?(key)
                  value.clone.map { |v| v.delete('id'); v }
                else
                  value.duplicable? ? value.clone : value
                end
        send("#{key}=", value)
      end

      write_attribute(:id, self.class.next_key(self))
    end
  end
end