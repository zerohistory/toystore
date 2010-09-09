module Toy
  module Serialization
    extend ActiveSupport::Concern
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    def serializable_hash(options = nil)
      hash = {}
      options ||= {}

      options[:only]   = Array.wrap(options[:only]).map { |n| n.to_s }
      options[:except] = Array.wrap(options[:except]).map { |n| n.to_s }

      attribute_names = attributes.keys.sort
      if options[:only].any?
        attribute_names &= options[:only]
      elsif options[:except].any?
        attribute_names -= options[:except]
      end

      method_names = Array.wrap(options[:methods]).inject([]) do |methods, name|
        methods << name if respond_to?(name.to_s)
        methods
      end

      attribute_names.each  { |name| hash[name] = attributes[name] }
      method_names.each     { |name| hash[name] = send(name) }

      serializable_add_includes(options) do |association, records, opts|
        hash[association] = records.is_a?(Enumerable) ?
          records.map { |r| r.serializable_hash(opts) } :
          records.serializable_hash(opts)
      end

      hash
    end

    private
      # Add associations specified via the <tt>:includes</tt> option.
      # Expects a block that takes as arguments:
      #   +association+ - name of the association
      #   +records+     - the association record(s) to be serialized
      #   +opts+        - options for the association records
      def serializable_add_includes(options = {})
        return unless include_associations = options.delete(:include)

        base_only_or_except = { :except => options[:except],
                                :only => options[:only] }

        include_has_options = include_associations.is_a?(Hash)
        associations = include_has_options ? include_associations.keys : Array.wrap(include_associations)

        for association in associations
          records = if self.class.lists.include?(association)
            send(association).to_a
          elsif self.class.references.include?(association)
            send(association)
          end

          unless records.nil?
            association_options = include_has_options ? include_associations[association] : base_only_or_except
            opts = options.merge(association_options)
            yield(association, records, opts)
          end
        end

        options[:include] = include_associations
      end
  end
end