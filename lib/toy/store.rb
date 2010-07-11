module Toy
  module Store
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes
      include Persistence
      include Querying

      include Callbacks
      include Validations
      include Serialization
    end
  end
end