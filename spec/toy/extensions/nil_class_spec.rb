require 'helper'

describe "NilClass#from_store" do
  it "should return nil" do
    nil.from_store(nil).should be_nil
  end
end

describe "NilClass#to_store" do
  it "should return nil" do
    nil.to_store(nil).should be_nil
  end
end

