require 'helper'

describe "Time.to_store without Time.zone" do
  before :each do
    Time.zone = nil
  end

  it "should be time to milliseconds if string" do
    Time.to_store('2000-01-01 01:01:01.123456').to_f.should == Time.local(2000, 1, 1, 1, 1, 1, 0).utc.to_f
  end

  it "should be time in utc if time" do
    Time.to_store(Time.local(2009, 8, 15, 0, 0, 0)).zone.should == 'UTC'
  end

  it "should be nil if blank string" do
    Time.to_store('').should be_nil
  end

  it "should not be nil if nil" do
    Time.to_store(nil).should be_nil
  end
end

describe "Time.to_store with Time.zone" do
  it "should be time to milliseconds if time" do
    Time.zone = 'Hawaii'
    Time.to_store(Time.zone.local(2009, 8, 15, 14, 0, 0, 123456)).to_f.should == Time.utc(2009, 8, 16, 0, 0, 0, 0).to_f
    Time.zone = nil
  end

  it "should be time to milliseconds if string" do
    Time.zone = 'Hawaii'
    Time.to_store('2009-08-15 14:00:00.123456').to_f.should == Time.utc(2009, 8, 16, 0, 0, 0, 0).to_f
    Time.zone = nil
  end

  it "should not round up times at the end of the month" do
    Time.to_store(Time.now.end_of_month).to_i.should == Time.now.end_of_month.utc.to_i
  end

  it "should be nil if blank string" do
    Time.zone = 'Hawaii'
    Time.to_store('').should be_nil
    Time.zone = nil
  end

  it "should be nil if nil" do
    Time.zone = 'Hawaii'
    Time.to_store(nil).should be_nil
    Time.zone = nil
  end
end

describe "Time.from_store without Time.zone" do
  it "should be time in utc" do
    time = Time.now
    Time.from_store(time).should be_within(1).of(time.utc)
  end

  it "should be time if string" do
    time = Time.now
    Time.from_store(time.to_s).should be_within(1).of(time)
  end

  it "should be nil if nil" do
    Time.from_store(nil).should be_nil
  end
end

describe "Time.from_store with Time.zone" do
  before do
    Time.zone = 'Hawaii'
  end

  after do
    Time.zone = nil
  end

  it "should be time in Time.zone" do
    time = Time.from_store(Time.utc(2009, 10, 1))
    time.should == Time.zone.local(2009, 9, 30, 14)
    time.is_a?(ActiveSupport::TimeWithZone).should be_true
  end

  it "should be time if string" do
    time = Time.zone.now
    Time.from_store(time.to_s).should be_within(1).of(time)
  end

  it "should be nil if nil" do
    Time.from_store(nil).should be_nil
  end
end