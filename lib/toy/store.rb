module Toy
  module Store
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
    end

    def persisted?
      false
    end
  end
end