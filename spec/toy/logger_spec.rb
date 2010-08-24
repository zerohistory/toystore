require 'helper'

describe Toy::Logger do
  uses_constants("User")
  it "should use Toy.logger for class" do
    User.logger.should == Toy.logger
  end
  
  it "should use Toy.logger for instance" do
    User.new.logger.should == Toy.logger
  end
end