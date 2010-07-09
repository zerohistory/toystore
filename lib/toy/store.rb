# encoding: UTF-8
module Toy
  module Store
    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include Attributes
      include Callbacks
      include Persistence
      include Validations
      include Querying
    end
  end
end