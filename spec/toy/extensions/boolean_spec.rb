require 'helper'

describe "Boolean.to_store" do
  it "should be true for true" do
    Boolean.to_store(true).should be_true
  end

  it "should be false for false" do
    Boolean.to_store(false).should be_false
  end

  it "should handle odd assortment of other values" do
    Boolean.to_store('true').should be_true
    Boolean.to_store('t').should be_true
    Boolean.to_store('1').should be_true
    Boolean.to_store(1).should be_true

    Boolean.to_store('false').should be_false
    Boolean.to_store('f').should be_false
    Boolean.to_store('0').should be_false
    Boolean.to_store(0).should be_false
  end

  it "should be nil for nil" do
    Boolean.to_store(nil).should be_nil
  end
end

describe "Boolean.from_store" do
  it "should be true for true" do
    Boolean.from_store(true).should be_true
  end

  it "should be false for false" do
    Boolean.from_store(false).should be_false
  end

  it "should be nil for nil" do
    Boolean.from_store(nil).should be_nil
  end
end
