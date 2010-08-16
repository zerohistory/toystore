require 'helper'

describe Toy::Dirty do
  uses_constants('User', 'Person')
  
  describe "#eql?" do
    it "returns true if same class and id" do
      User.new(:id => 1).should eql(User.new(:id => 1))
    end
    
    it "return false if different class" do
      User.new(:id => 1).should_not eql(Person.new(:id => 1))
    end
    
    it "returns false if different id" do
      User.new(:id => 1).should_not eql(User.new(:id => 2))
    end
  end
  
end