require 'helper'

describe Toy::Caching do
  uses_constants('User')

  context "new" do
    before do
      @user = User.new
    end

    it "should be class:new" do
      @user.cache_key.should == 'User:new'
    end

    it "should work with suffix" do
      @user.cache_key(:foo).should == 'User:new:foo'

      @user.cache_key(:foo, :bar).should == 'User:new:foo:bar'
    end
  end

  context "not new" do
    context "with updated_at" do
      before do
        User.timestamps
        @now = Time.now.utc
        Timecop.freeze(@now) do
          @user = User.create
        end
      end

      it "should be class:id-timestamp" do
        @user.cache_key.should == "User:#{@user.id}-#{@now.to_s(:number)}"
      end

      it "should work with suffix" do
        @user.cache_key(:foo).should == "User:#{@user.id}-#{@now.to_s(:number)}:foo"

        @user.cache_key(:foo, :bar).should == "User:#{@user.id}-#{@now.to_s(:number)}:foo:bar"
      end
    end

    context "without updated_at" do
      before do
        @now = Time.now.utc
        Timecop.freeze(@now) do
          @user = User.create
        end
      end

      it "should be class:id" do
        @user.cache_key.should == "User:#{@user.id}"
      end

      it "should work with suffix" do
        @user.cache_key(:foo).should == "User:#{@user.id}:foo"

        @user.cache_key(:foo, :bar, :baz). should == "User:#{@user.id}:foo:bar:baz"
      end
    end
  end
end