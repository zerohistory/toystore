require 'helper'

describe Toy::Querying do
  before      { @model = Model() { attribute :name, String } }
  let(:model) { @model }

  describe ".[]" do
    it "returns loaded document" do
      john = model.create(:name => 'John')
      model[john.id].name.should == 'John'
    end
  end

  describe ".key?" do
    it "returns true if key exists" do
      doc = model.create(:name => 'John')
      model.key?(doc.id).should be_true
    end

    it "returns false if key does not exist" do
      model.key?('taco:bell:tacos').should be_false
    end
  end

  describe ".has_key?" do
    it "returns true if key exists" do
      doc = model.create(:name => 'John')
      model.has_key?(doc.id).should be_true
    end

    it "returns false if key does not exist" do
      model.has_key?('taco:bell:tacos').should be_false
    end
  end

  describe ".load" do
    before    { @doc = model.create(:name => 'John') }
    let(:doc) { @doc }

    it "marks object as persisted" do
      doc.should be_persisted
    end

    it "decodes the object" do
      model[doc.id].name.should == 'John'
    end
  end
end