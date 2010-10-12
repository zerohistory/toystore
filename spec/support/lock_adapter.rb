shared_examples_for 'lock adapter' do
  let(:lock)      { @lock }
  let(:lock_name) { @lock_name }

  describe "#set_expiration_if_not_exists" do
    describe "(with lock not found)" do
      before do
        @result = lock.set_expiration_if_not_exists(15)
      end

      it "returns true" do
        @result.should be_true
      end

      it "sets the value" do
        lock.adapter.read(lock_name).should == 15
      end
    end

    describe "(with lock found)" do
      before do
        lock.adapter.write(lock_name, 25)
        @result = lock.set_expiration_if_not_exists(15)
      end

      it "returns false" do
        @result.should be_false
      end

      it "does not set the value" do
        lock.adapter.read(lock_name).should == 25
      end
    end
  end

  describe "#getset" do
    describe "with lock not found" do
      before do
        @result = lock.getset(15)
      end

      it "returns nil" do
        @result.should be_nil
      end

      it "sets new value" do
        lock.adapter.read(lock_name).should == 15
      end
    end

    describe "with lock found" do
      before do
        lock.adapter.write(lock_name, 25)
        @result = lock.getset(15)
      end

      it "returns old value" do
        @result.should == 25
      end

      it "sets new value" do
        lock.adapter.read(lock_name).should == 15
      end
    end
  end
end