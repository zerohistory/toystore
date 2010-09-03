module IdentityMapMatcher
  class BeInIdentityMap
    def matches?(obj)
      @obj = obj
      @obj.identity_map[@obj.store_key] == @obj
    end

    def failure_message
      "expected #{@obj} to be in identity map, but it was not"
    end

    def negative_failure_message
      "expected #{@obj} to not be in identity map, but it was"
    end
  end

  def be_in_identity_map
    BeInIdentityMap.new
  end
end