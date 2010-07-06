require 'helper'

describe Toy::Persistence do
  before do
    @model = Model()
  end
  let(:model) { @model }

  describe ".store" do
    it "returns store if no argument" do
      model.store Moneta::MongoDB.new
      model.store.should be_instance_of(Moneta::MongoDB)
    end

    it "sets store if argument" do
      model.store Moneta::File.new(:path => 'testing')
      model.store.should be_instance_of(Moneta::File)
    end
  end

  xit "creates" do
    model.attribute :name
    model.attribute :age
    model.create(:name => 'John', :age => 28)
  end
end