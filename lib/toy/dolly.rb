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

      self.class.lists.each do |name, list|
        instance_variable_set(list.instance_variable, nil)
      end

      other.attributes.except('id').each do |key, value|
        value = value.duplicable? ? value.clone : value
        send("#{key}=", value)
      end

      other.class.embedded_lists.keys.each do |name|
        send("#{name}=", other.send(name).map(&:clone))
      end

      write_attribute(:id, self.class.next_key(self))
    end
  end
end