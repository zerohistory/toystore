require 'helper'

describe Toy::Connection do
  uses_constants('User')

  before do
    @logger = Toy.logger
  end

  after do
    Toy.logger = @logger
  end

  describe "store" do
    it "should set the default store" do
      Toy.store(MemoryStore)
      Toy.store.should == MemoryStore
    end

    it "including Toy::Store should use the default store, if present" do
      Toy.store(MemoryStore)
      klass = Class.new { include Toy::Store }
      klass.store.should == MemoryStore
    end

    describe "with symbol" do
      before do
        Toy.store(:file, :path => 'testing')
      end

      it "constantizes and sets up moneta builder correctly" do
        # Moneta does not expose anything and Moneta::Builder has no
        # equality knowledge so we have to dig in unfortunately.
        adapter = Toy.store.instance_variable_get("@adapter")
        adapter.should be_instance_of(Moneta::Adapters::File)
        adapter.instance_variable_get("@directory").should == 'testing'
      end
    end

    describe "with string" do
      before do
        Toy.store('file', :path => 'testing')
      end

      it "constantizes and sets up moneta builder correctly" do
        # Moneta does not expose anything and Moneta::Builder has no
        # equality knowledge so we have to dig in unfortunately.
        adapter = Toy.store.instance_variable_get("@adapter")
        adapter.should be_instance_of(Moneta::Adapters::File)
        adapter.instance_variable_get("@directory").should == 'testing'
      end
    end

  end

  describe "logger" do
    it "should set the default logger" do
      logger = stub
      Toy.logger = logger
      Toy.logger.should == logger
    end

    it "should be an instance of Logger if not set" do
      Toy.logger = nil
      Toy.logger.should be_instance_of(Logger)
    end

    it "should use RAILS_DEFAULT_LOGGER if defined" do
      remove_constants("RAILS_DEFAULT_LOGGER")
      RAILS_DEFAULT_LOGGER = stub

      Toy.logger = nil
      Toy.logger.should == RAILS_DEFAULT_LOGGER
    end
  end

  describe "key_factory" do
    it "should set the default key_factory" do
      key_factory = stub
      Toy.key_factory = key_factory
      Toy.key_factory.should == key_factory
    end

    it "should default to the UUIDKeyFactory" do
      Toy.key_factory = nil
      Toy.key_factory.should be_instance_of(Toy::Identity::UUIDKeyFactory)
    end
  end
end
