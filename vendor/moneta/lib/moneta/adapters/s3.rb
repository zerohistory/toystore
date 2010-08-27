require "moneta/adapters/fog"

module Moneta
  module Adapters
    class S3 < Fog

      def initialize(options)
        options[:cloud] = ::Fog::AWS::S3
        super
      end

    end
  end
end
