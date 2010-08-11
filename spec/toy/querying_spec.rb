require 'helper'

describe Toy::Querying do
  uses_constants('User')

  before do
    User.attribute :name, String
  end

  describe ".[]" do
    it "returns loaded document" do
      john = User.create(:name => 'John')
      User[john.id].name.should == 'John'
    end
  end

  describe ".key?" do
    it "returns true if key exists" do
      doc = User.create(:name => 'John')
      User.key?(doc.id).should be_true
    end

    it "returns false if key does not exist" do
      User.key?('taco:bell:tacos').should be_false
    end
  end

  describe ".has_key?" do
    it "returns true if key exists" do
      doc = User.create(:name => 'John')
      User.has_key?(doc.id).should be_true
    end

    it "returns false if key does not exist" do
      User.has_key?('taco:bell:tacos').should be_false
    end
  end

  describe ".load" do
    before    { @doc = User.create(:name => 'John') }
    let(:doc) { @doc }

    it "marks object as persisted" do
      doc.should be_persisted
    end

    it "decodes the object" do
      User[doc.id].name.should == 'John'
    end
  end
end