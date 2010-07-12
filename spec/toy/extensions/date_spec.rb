require 'helper'

describe "Date.to_store" do
  it "should be time if string" do
    date = Date.to_store('2009-10-01')
    date.should == Time.utc(2009, 10, 1)
    date.should == date
    date.month.should == 10
    date.day.should == 1
    date.year.should == 2009
  end

  it "should be time if date" do
    Date.to_store(Date.new(2009, 10, 1)).should == Time.utc(2009, 10, 1)
  end

  it "should be date if time" do
    Date.to_store(Time.parse("2009-10-1T12:30:00")).should == Time.utc(2009, 10, 1)
  end

  it "should be nil if bogus string" do
    Date.to_store('jdsafop874').should be_nil
  end

  it "should be nil if empty string" do
    Date.to_store('').should be_nil
  end
end

describe "Date.from_store" do
  it "should be date if date" do
    date = Date.new(2009, 10, 1)
    from_date = Date.from_store(date)
    from_date.should == date
    from_date.month.should == 10
    from_date.day.should == 1
    from_date.year.should == 2009
  end

  it "should be date if time" do
    time = Time.now
    Date.from_store(time).should == time.to_date
  end

  it "should be nil if nil" do
    Date.from_store(nil).should be_nil
  end
end
