require 'helper'

describe Toy::Attributes do
  uses_constants('User')

  before do
    User.attribute(:name, String)
    User.attribute(:age, Integer)
  end

  it "prints out object id and attributes sorted with values" do
    user = User.new(:age => 28, :name => 'John')
    user.inspect.should == %Q(#<User:#{user.object_id} age: 28, id: "#{user.id}", name: "John">)
  end
end