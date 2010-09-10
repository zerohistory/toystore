require 'helper'

describe Toy::Validations do
  uses_constants('User', 'Game', 'Move')

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
    context "with valid" do
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

    context "with invalid" do
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

    context "with invalid option" do
      it "raises error" do
        lambda { User.new.save(:foobar => '') }.should raise_error
      end
    end

    context "with :validate option" do
      before do
        User.validates_presence_of(:name)
        @doc = User.new
      end

      it "does not perform validations if false" do
        @doc.save(:validate => false).should be_true
        User.key?(@doc.id).should be_true
      end

      it "does perform validations if true" do
        @doc.save(:validate => true).should be_false
        User.key?(@doc.id).should be_false
      end
    end
  end

  describe "#save!" do
    context "with valid" do
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

    context "with invalid" do
      before do
        @doc = User.new
      end

      it "raises an RecordInvalidError" do
        lambda { @doc.save! }.should raise_error(Toy::RecordInvalidError)
      end
    end
  end

  describe "#create!" do
    context "with valid" do
      it "persists the instance" do
        @doc = User.create!(:name => 'John')
        @doc.should be_persisted
      end
    end

    context "with invalid" do
      it "raises an RecordInvalidError" do
        lambda { User.create! }.should raise_error(Toy::RecordInvalidError)
      end
    end
  end

  describe ".validates_embedded" do
    before do
      Game.embedded_list(:moves)
      Move.attribute(:index, Integer)
      Move.validates_presence_of(:index)
      Game.validates_embedded(:moves)
    end

    it "adds errors if any of the embedded are invalid" do
      game = Game.new(:moves => [Move.new])
      game.valid?
      game.errors[:moves].should include('is invalid')
    end

    it "does not have errors if all embedded are valid" do
      game = Game.new(:moves => [Move.new(:index => 1)])
      game.valid?
      game.errors[:moves].should_not include('is invalid')
    end
  end
end