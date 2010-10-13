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

  class UndefinedLock < Error
    def initialize(klass, name)
      super("Undefined lock :#{name} for class #{klass.name}")
    end
  end

  class AdapterNoLocky < Error
    def initialize(adapter)
      super("#{adapter.name.to_s.capitalize} adapter does not support locking")
    end
  end
end