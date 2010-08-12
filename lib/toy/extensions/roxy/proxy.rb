module Roxy
  class Proxy
    alias :initialize_without_reflection :initialize

    # The proxy needs to know about itself so we can get key and such
    def initialize(owner, options, args, &block)
      initialize_without_reflection(owner, options, args, &block)
      @reflection = options[:reflection]
    end

    def proxy_reflection
      @reflection
    end
  end
end