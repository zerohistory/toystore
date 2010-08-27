require 'helper'

describe Toy::Persistence do
  uses_constants('User')

  describe ".store" do
    it "returns store if no argument" do
      User.store(MongoStore)
      User.store.should be(MongoStore)
    end

    it "sets store if argument" do
      User.store(FileStore)
      User.store.should be(FileStore)
    end
  end

  describe ".store_key" do
    it "returns plural model name and id" do
      doc = User.new
      User.store_key(doc.id).should == "users:#{doc.id}"
    end
  end

  describe ".create" do
    before do
      User.attribute :name, String
      User.attribute :age, Integer
      @doc = User.create(:name => 'John', :age => 50)
    end
    let(:doc) { @doc }

    it "creates key in database with value that is json dumped" do
      value = User.store[doc.store_key]
      Toy.decode(value).should == {
        'name' => 'John',
        'id'   => doc.id,
        'age'  => 50,
      }
    end

    it "returns instance of model" do
      doc.should be_instance_of(User)
    end
  end

  describe "#store" do
    it "delegates to class" do
      User.store.should equal(User.new.store)
    end
  end

  describe "#store_key" do
    it "returns pluralized human name and id" do
      doc = User.new
      doc.store_key.should == "users:#{doc.id}"
    end
  end

  describe "#new_record?" do
    it "returns true if new" do
      User.new.should be_new_record
    end

    it "returns false if not new" do
      User.create.should_not be_new_record
    end
  end

  describe "#persisted?" do
    it "returns true if persisted" do
      User.create.should be_persisted
    end

    it "returns false if not persisted" do
      User.new.should_not be_persisted
    end
    
    it "returns false if deleted" do
      doc = User.create
      doc.delete
      doc.should_not be_persisted
    end
  end

  describe "#save" do
    before do
      User.attribute :name, String
      User.attribute :age, Integer
    end

    describe "with new record" do
      it "saves to key" do
        doc = User.new(:name => 'John')
        doc.save
        User.key?(doc.id)
      end
    end

    describe "with existing record" do
      before do
        @doc      = User.create(:name => 'John')
        @key      = @doc.store_key
        @value    = User.store[@doc.store_key]
        @doc.name = 'Bill'
        @doc.save
      end
      let(:doc) { @doc }

      it "stores in same key" do
        doc.store_key.should == @key
      end

      it "updates value in store" do
        User.store[doc.store_key].should_not == @value
      end

      it "updates the attributes in the instance" do
        doc.name.should == 'Bill'
      end
    end
  end
  
  describe "#update_attributes" do
    before do
      User.attribute :name, String
    end
    
    it "should change attribute and save" do
      user = User.create(:name => 'John')
      User.get(user.id).name.should == 'John'

      user.update_attributes(:name => 'Geoffrey')
      User.get(user.id).name.should == 'Geoffrey'
    end
  end
  
  describe "#delete" do
    it "should remove the instance from the store" do
      doc = User.create
      doc.delete
      
      User.key?(doc.id).should be_false
    end
  end
  
  describe "#destroy" do
    it "should remove the instance from the store" do
      doc = User.create
      doc.destroy
      
      User.key?(doc.id).should be_false
    end
  end
  
  describe "#destroyed?" do
    it "should be false if not deleted" do
      doc = User.create
      doc.should_not be_destroyed
    end
    
    it "should be true if deleted" do
      doc = User.create
      doc.delete
      
      doc.should be_destroyed
    end
  end
  
  describe ".delete(*ids)" do
    it "should delete a single record" do
      doc = User.create

      User.delete(doc.id)
      
      User.key?(doc.id).should be_false
    end
    
    it "should delete multiple records" do
      doc1 = User.create
      doc2 = User.create
      
      User.delete(doc1.id, doc2.id)
      
      User.key?(doc1.id).should be_false
      User.key?(doc2.id).should be_false
    end
    
    it "should not complain when records do not exist" do
      doc = User.create

      User.delete("taco:bell:tacos")
    end    
  end
  
  describe ".destroy(*ids)" do
    it "should destroy a single record" do
      doc = User.create

      User.destroy(doc.id)
      
      User.key?(doc.id).should be_false
    end
    
    it "should destroy multiple records" do
      doc1 = User.create
      doc2 = User.create
      
      User.destroy(doc1.id, doc2.id)
      
      User.key?(doc1.id).should be_false
      User.key?(doc2.id).should be_false
    end
    
    it "should not complain when records do not exist" do
      doc = User.create

      User.destroy("taco:bell:tacos")
    end
  end
  
end