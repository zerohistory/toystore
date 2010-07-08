begin
  require "xattr"
rescue LoadError
  puts "You need the xattr gem to use the Xattr moneta store"
  exit
end
require "fileutils"

module Moneta
  class Xattr
    include Defaults

    def initialize(options = {})
      file = options[:file]
      @store = ::Xattr.new(file)
      FileUtils.mkdir_p(::File.dirname(file))
      FileUtils.touch(file)
      unless options[:skip_expires]
        @expiration = Moneta::Xattr.new(:file => "#{file}_expiration", :skip_expires => true)
        self.extend(Expires)
      end
    end

    module Implementation

      def key?(key)
        @store.list.include?(key)
      end

      alias has_key? key?

      def [](key)
        return nil unless key?(key)
        Marshal.load(@store.get(key))
      end

      def []=(key, value)
        @store.set(key, Marshal.dump(value))
      end

      def delete(key)
        return nil unless key?(key)
        value = self[key]
        @store.remove(key)
        value
      end

      def clear
        @store.list.each do |item|
          @store.remove(item)
        end
      end

    end
    include Implementation

  end
end