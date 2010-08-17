require 'helper'

describe Toy::Timestamps do
  uses_constants('User')

  before do
    User.timestamps
  end

  it "adds created_at attribute" do
    User.attribute?(:created_at)
  end

  it "adds updated_at attribute" do
    User.attribute?(:updated_at)
  end

  describe "on create" do
    before do
      @now = Time.now.utc
      Timecop.freeze(@now) do
        @user = User.create
      end
    end

    it "sets created at" do
      @user.created_at.to_i.should == @now.to_i
    end

    it "sets updated at" do
      @user.updated_at.to_i.should == @now.to_i
    end

    it "uses created_at if provided" do
      yesterday = @now - 1.day
      @user = User.create(:created_at => yesterday)
      @user.created_at.to_i.should == yesterday.to_i
    end
  end

  describe "on update" do
    before do
      @now       = Time.now.utc
      @yesterday = @now - 1.day

      Timecop.freeze(@yesterday) do
        @user = User.create
      end

      Timecop.freeze(@now) do
        @user.save
      end
    end

    it "does not change created at" do
      @user.created_at.to_i.should == @yesterday.to_i
    end

    it "updates updated at" do
      @user.updated_at.to_i.should == @now.to_i
    end
  end
end