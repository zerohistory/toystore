require 'helper'

describe Toy::Identity::AbstractKeyFactory do
  it "should raise not implemented error for #next_key" do
    lambda { Toy::Identity::AbstractKeyFactory.new.next_key("any object") }.should raise_error(NotImplementedError)
  end
end