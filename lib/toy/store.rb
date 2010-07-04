module Toy
  module Store
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes
    end

    def persisted?
      false
    end
  end
end