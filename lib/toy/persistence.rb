# encoding: UTF-8
module Toy
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def store(new_store=nil)
        @store = new_store unless new_store.nil?
        @store
      end
    end
  end
end