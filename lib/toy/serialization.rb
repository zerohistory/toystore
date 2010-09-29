module Toy
  module Serialization
    extend ActiveSupport::Concern
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    def serializable_attributes
      attributes.keys.sort.map(&:to_sym)
    end

    def serializable_hash(options = nil)
      hash = {}
      options ||= {}
      # so attributes only gets called once and thus only does one hash merge and lookup of values
      attrs            = attributes
      options[:only]   = Array.wrap(options[:only]).map { |n| n.to_sym }
      options[:except] = Array.wrap(options[:except]).map { |n| n.to_sym }

      serializable_stuff = serializable_attributes + Array.wrap(options[:methods])

      if options[:only].any?
        serializable_stuff &= options[:only]
      elsif options[:except].any?
        serializable_stuff -= options[:except]
      end

      serializable_stuff.each do |name|
        if self.class.attribute?(name) || self.class.embedded_list?(name)
          hash[name.to_s] = attrs[name]
        else
          if respond_to?(name.to_s)
            result = send(name)
            hash[name.to_s] = result.respond_to?(:serializable_hash) ?
                                result.serializable_hash : result
          end
        end
      end

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
          records = if self.class.list?(association)
            send(association).to_a
          elsif self.class.reference?(association) || self.class.parent_reference?(association)
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