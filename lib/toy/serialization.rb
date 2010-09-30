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
      options[:only]   = Array.wrap(options[:only]).map(&:to_sym)
      options[:except] = Array.wrap(options[:except]).map(&:to_sym)

      serializable_stuff = serializable_attributes.map(&:to_sym) + self.class.embedded_lists.keys.map(&:to_sym)

      if options[:only].any?
        serializable_stuff &= options[:only]
      elsif options[:except].any?
        serializable_stuff -= options[:except]
      end

      serializable_stuff += Array.wrap(options[:methods]).map(&:to_sym).select do |method|
        respond_to?(method)
      end

      serializable_stuff.each do |name|
        value = send(name)
        hash[name.to_s] = if value.is_a?(Array)
                            value.map { |v| v.respond_to?(:serializable_hash) ? v.serializable_hash : v }
                          elsif value.respond_to?(:serializable_hash)
                            value.serializable_hash
                          else
                            value
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