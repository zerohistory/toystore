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

  class LockTimeout < Error
    def initialize(key, timeout)
      super("Timeout on lock #{key} exceeded #{timeout} sec")
    end
  end

end