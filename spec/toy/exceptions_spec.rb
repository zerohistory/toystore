require 'helper'

describe Toy::RecordInvalidError do
  uses_constants('User')

  before do
    class User
      attribute :name, String
      attribute :age, Integer
      validates_presence_of :name
      validates_presence_of :age
    end
  end
  
  it "should include a message of the errors" do
    user = User.new
    user.should_not be_valid
    Toy::RecordInvalidError.new(user).message.should == "Invalid record: Name can't be blank and Age can't be blank"
  end
end