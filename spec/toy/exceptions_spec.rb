require 'helper'

describe Toy::RecordInvalidError do
  before :each do
    @model = Model('User') do
      attribute :name, String
      attribute :age, Integer
      validates_presence_of :name
      validates_presence_of :age
    end
  end
  let(:model) { @model }
  
  it "should include a message of the errors" do
    user = model.new
    user.should_not be_valid
    Toy::RecordInvalidError.new(user).message.should == "Invalid record: Name can't be blank and Age can't be blank"
  end
end