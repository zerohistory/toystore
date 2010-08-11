require 'helper'

describe Toy::Dirty do
  uses_constants('Foo')

  before do
    class Foo
      store RedisStore
      attribute :name, String
    end
    @foo = Foo.create(:name => 'Geoffrey')
  end
  let(:foo) { @foo }
  
  it "should identify when there are no changes" do
    foo.changed?.should be_false
    foo.changed.should be_empty
    foo.changes.should be_empty
  end
  
  it "should identify when there are changes" do
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