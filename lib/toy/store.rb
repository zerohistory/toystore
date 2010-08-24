module Toy
  module Store
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes
      include Identity
      include Persistence
      include Dirty
      include Equality
      include Querying

      include Callbacks
      include Validations
      include Serialization
      include Timestamps

      include Lists
      include References
      include Indices
    end
  end
end