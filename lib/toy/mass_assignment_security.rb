module Toy
  module MassAssignmentSecurity
    extend ActiveSupport::Concern
    include ActiveModel::MassAssignmentSecurity

    module InstanceMethods
      def initialize(attrs={})
        super(sanitize_for_mass_assignment(attrs || {}))
      end

      def update_attributes(attrs={})
        super(sanitize_for_mass_assignment(attrs || {}))
      end
    end
  end
end