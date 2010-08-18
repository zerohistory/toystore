require 'helper'

describe Toy::Indices do
  uses_constants('User')

  it "defaults lists to empty hash" do
    User.indices.should == {}
  end

  describe "declaring a list" do
    before do
      User.attribute :ssn, String
      @index = User.index(:ssn)
    end

    it "knows about its lists" do
      User.indices[:ssn].should == Toy::Index.new(User, :ssn)
    end

    it "returns list" do
      @index.should == Toy::Index.new(User, :ssn)
    end
  end

end