module Toy
  module Store
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes
      include Identity
      include Persistence
      include Accessible
      include Protected
      include Plugins
      include Dolly
      include Dirty
      include Equality
      include Inspect
      include Querying

      include Callbacks
      include Validations
      include Serialization
      include Timestamps

      include Lists
      include EmbeddedLists
      include References
      include Indices
      include Logger

      include IdentityMap
      include Caching
    end
  end

  extend Connection
end