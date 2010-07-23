require 'helper'

describe Toy::Lists do
  let(:model) do
    Model('User') do
      list :games
    end
  end

  it "knows about its lists" do
    model.lists[:games].should == Toy::List.new(model, :games)
  end
end