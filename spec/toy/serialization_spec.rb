require 'helper'

describe Toy::Validations do
  before do
    @model = Model('User') do
      attribute :name
      attribute :age
    end
  end
  let(:model) { @model }

  it "serializes to json" do
    doc = model.new(:name => 'John', :age => 28)
    doc.to_json.should == %Q({"user":{"name":"John","id":"#{doc.id}","age":28}})
  end

  it "serializes to xml" do
    doc = model.new(:name => 'John', :age => 28)
    doc.to_xml.should == <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <name>John</name>
  <id>#{doc.id}</id>
  <age type="integer">28</age>
</user>
EOF
  end
end