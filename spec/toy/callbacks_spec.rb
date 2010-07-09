require 'helper'

describe Toy::Callbacks do
  before :all do
    @model = Model('Foo') do
      store Moneta::File.new(:path => 'testing')
      attribute :name
      
      after_create :set_after_create_called
      
      def set_after_create_called
        @after_create_called = true
      end
      
      def after_create_called?
        @after_create_called
      end
    end
  end
  let(:model) { @model }

  describe 'a newly created record' do
    xit 'should have had after_create called' do
      foo = model.create(:name => 'Geoffrey')
      
      foo.after_create_called?.should be_true
    end
  end
end