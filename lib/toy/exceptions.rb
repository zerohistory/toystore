module Toy
  class Error < StandardError; end

  class RecordInvalidError < Error
    attr_reader :record
    def initialize(record)
      @record = record
      super("Invalid record: #{@record.errors.full_messages.to_sentence}")
    end
  end

  class NotFound < Error
    def initialize(id)
      super("Could not find document with id: #{id.inspect}")
    end
  end

  class AccessibleOrProtected < Error
    def initialize(name)
      super("Declare either attr_protected or attr_accessible for #{name}, but not both.")
    end
  end
end