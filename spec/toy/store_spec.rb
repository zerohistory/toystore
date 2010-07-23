require 'helper'

describe Toy::Store do
  before      { @model = Model('User') }
  let(:model) { @model }
  
  describe "including" do
    it "adds model naming" do
      model_name = model.model_name
      model_name.should           == 'User'
      model_name.singular.should  == 'user'
      model_name.plural.should    == 'users'
    end

    it "adds to_model" do
      user = model.new
      user.to_model.should == user
    end

    describe "#to_key" do
      it "returns [id] if persisted" do
        user = model.create
        user.to_key.should == [user.id]
      end

      it "returns nil if not persisted" do
        model.new.to_key.should be_nil
      end
    end

    describe "#to_param" do
      it "returns key joined by - if to_key present" do
        user = model.create
        user.to_param.should == user.to_key.to_s
      end

      it "returns nil if to_key nil" do
        model.new.to_param.should be_nil
      end
    end
  end
end