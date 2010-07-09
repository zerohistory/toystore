require 'helper'

describe Toy::Dirty do
  before :each do
    model = Model('Foo') do
      store FileStore
      attribute :name
    end
    @foo = model.create(:name => 'Geoffrey')
  end
  let(:foo) { @foo }
  
  xit "should identify when there are no changes" do
    foo.changed?.should be_false
    foo.changed.should be_empty
    foo.changes.should be_empty
  end
  
  xit "should identify when there are changes" do
    foo.name = 'John'
    
    foo.changed?.should be_true
    foo.changed.should include('name')
    foo.changes.should == {'name' => ['Geoffrey', 'John']}
  end
  
  xit "should identify when an attributes has changed" do
    foo.name = 'John'
    
    foo.name_changed?.should be_true
    foo.name_changed.should == ['Geoffrey', 'John']
    foo.name_was.should == 'Geoffrey'
  end
  
  xit "should reset changes" do
    foo.name = 'John'
    
    foo.reset_name!
    foo.name.should == 'Geoffrey'
  end
end