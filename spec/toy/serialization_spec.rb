require 'helper'

describe Toy::Validations do
  uses_constants('User')

  before do
    User.attribute :name, String
    User.attribute :age, Integer
  end

  it "serializes to json" do
    doc = User.new(:name => 'John', :age => 28)
    doc.to_json.should == %Q({"user":{"name":"John","id":"#{doc.id}","age":28}})
  end

  it "serializes to xml" do
    doc = User.new(:name => 'John', :age => 28)
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