module Toy
  module Identity
    class UUIDKeyFactory < AbstractKeyFactory
      def next_key(object)
        SimpleUUID::UUID.new.to_guid
      end
    end
  end
end