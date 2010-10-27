require 'helper'

describe Toy::Logger do
  uses_constants('User')

  it "should use Toy.logger for class" do
    User.logger.should == Toy.logger
  end

  it "should use Toy.logger for instance" do
    User.new.logger.should == Toy.logger
  end

  describe ".log_operation" do
    let(:adapter) { Adapter[:memory].new({}) }

    it "logs operation" do
      User.logger.should_receive(:debug).with('ToyStore GET :memory "foo"')
      User.logger.should_receive(:debug).with('  "bar"')
      User.log_operation('GET', adapter, 'foo', 'bar')
    end
  end

  describe "#log_operation" do
    let(:adapter) { Adapter[:memory].new({}) }

    it "logs operation" do
      User.logger.should_receive(:debug).with('ToyStore GET :memory "foo"')
      User.logger.should_receive(:debug).with('  "bar"')
      User.log_operation('GET', adapter, 'foo', 'bar')
    end
  end
end