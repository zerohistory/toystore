require 'helper'

describe Toy::Validations do
  uses_constants('User')

  before do
    User.class_eval do
      attribute :name, String
      validates_presence_of :name

      [:before_validation, :after_validation].each do |callback|
        callback_method = "#{callback}_callback"
        send(callback, callback_method)
        define_method(callback_method) { history << callback.to_sym }
      end

      def history
        @history ||= []
      end
    end
  end

  it "runs validation callbacks around valid?" do
    doc = User.new(:name => 'John')
    doc.valid?
    doc.history.should == [:before_validation, :after_validation]
  end

  describe "validate callback" do
    before do
      User.class_eval do
        attribute :name, String
        validate :name_not_john

        private
          def name_not_john
            errors.add(:name, 'cannot be John') if name == 'John'
          end
      end
    end

    it "adds error if fails" do
      doc = User.new(:name => 'John')
      doc.valid?
      doc.errors[:name].should include('cannot be John')
    end

    it "does not add error if all good" do
      doc = User.new(:name => 'Frank')
      doc.should be_valid
    end
  end

  describe "#save" do
    describe "with valid" do
      before do
        @doc = User.new(:name => 'John')
        @result = @doc.save
      end

      it "returns true" do
        @result.should be_true
      end

      it "persists the instance" do
        @doc.should be_persisted
      end
    end

    describe "with invalid" do
      before do
        @doc = User.new
        @result = @doc.save
      end

      it "returns false" do
        @result.should be_false
      end

      it "does not persist instance" do
        @doc.should_not be_persisted
      end
    end
  end

  describe "#save!" do
    describe "with valid" do
      before do
        @doc = User.new(:name => 'John')
        @result = @doc.save!
      end

      it "returns true" do
        @result.should be_true
      end

      it "persists the instance" do
        @doc.should be_persisted
      end
    end

    describe "with invalid" do
      before do
        @doc = User.new
      end

      it "raises an RecordInvalidError" do
        lambda { @doc.save! }.should raise_error(Toy::RecordInvalidError)
      end
    end
  end

  describe "#create!" do
    describe "with valid" do
      it "persists the instance" do
        @doc = User.create!(:name => 'John')
        @doc.should be_persisted
      end
    end

    describe "with invalid" do
      it "raises an RecordInvalidError" do
        lambda { User.create! }.should raise_error(Toy::RecordInvalidError)
      end
    end
  end

end