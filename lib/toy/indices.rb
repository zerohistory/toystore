module Toy
  module Indices
    extend ActiveSupport::Concern
    
    module ClassMethods
      def indices
        @indices ||= {}
      end

      def index(name)
        Index.new(self, name)
      end
    end
  end
end