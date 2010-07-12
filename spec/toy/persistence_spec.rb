require 'helper'

describe Toy::Persistence do
  before      { @model = Model('User') }
  let(:model) { @model }

  describe ".store" do
    it "returns store if no argument" do
      model.store MongoStore
      model.store.should be_instance_of(Moneta::MongoDB)
    end

    it "sets store if argument" do
      model.store FileStore
      model.store.should be_instance_of(Moneta::File)
    end
  end

  describe ".store_key" do
    it "returns plural model name and id" do
      doc = model.new
      model.store_key(doc.id).should == "users:#{doc.id}"
    end
  end

  describe ".create" do
    before do
      model.attribute :name, String
      model.attribute :age, Integer
      @doc = model.create(:name => 'John', :age => 50)
    end
    let(:doc) { @doc }

    it "creates key in database with value that is json dumped" do
      value = model.store[doc.store_key]
      Toy.decode(value).should == {
        'name' => 'John',
        'id'   => doc.id,
        'age'  => 50,
      }
    end

    it "returns instance of model" do
      doc.should be_instance_of(model)
    end
  end

  describe "#store" do
    it "delegates to class" do
      model.store.should equal(model.new.store)
    end
  end

  describe "#store_key" do
    it "returns pluralized human name and id" do
      doc = model.new
      doc.store_key.should == "users:#{doc.id}"
    end
  end

  describe "#new_record?" do
    it "returns true if new" do
      model.new.should be_new_record
    end

    it "returns false if not new" do
      model.create.should_not be_new_record
    end
  end

  describe "#persisted?" do
    it "returns true if persisted" do
      model.create.should be_persisted
    end

    it "returns false if not persisted" do
      model.new.should_not be_persisted
    end
  end

  describe "#save" do
    before do
      model.attribute :name, String
      model.attribute :age, Integer
    end

    describe "with new record" do
      it "saves to key" do
        doc = model.new(:name => 'John')
        doc.save
        model.key?(doc.id)
      end
    end

    describe "with existing record" do
      before do
        @doc      = model.create(:name => 'John')
        @key      = @doc.store_key
        @value    = model.store[@doc.store_key]
        @doc.name = 'Bill'
        @doc.save
      end
      let(:doc) { @doc }

      it "stores in same key" do
        doc.store_key.should == @key
      end

      it "updates value in store" do
        model.store[doc.store_key].should_not == @value
      end

      it "updates the attributes in the instance" do
        doc.name.should == 'Bill'
      end
    end
  end
end