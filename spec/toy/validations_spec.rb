require 'helper'

describe Toy::Validations do
  it "should include ActiveModel validations" do
    @model = Model('Foo') do
      attribute :name
      validates_presence_of :name
    end
    
    @model.new(:name => nil).should_not be_valid
    @model.new(:name => 'something').should be_valid
  end
end