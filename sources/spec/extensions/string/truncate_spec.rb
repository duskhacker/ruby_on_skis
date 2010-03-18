require File.dirname(__FILE__) + '/../../spec_helper'

describe Extensions::String::Truncate do
  it "should leave strings of less than 20 unchanged" do
    "test".truncate.should == "test"
  end
  
  it "should truncate strings of more than 20 chars by default" do
     'Lorem ipsum dolor sit amet, consectetur'.truncate.should == "Lorem ipsum dolor..."
  end

  it "should take an argument to determine the length of the truncation" do
    'Lorem ipsum dolor sit amet, consectetur'.truncate(30).should == "Lorem ipsum dolor sit amet,..."
  end
  
  it "should return the original string if the truncation size is less than the size of the ellipses" do
    "test".truncate(1).truncate.should == "test"
  end
  
  it "should return the original string if the size of the string would be exactly the same with the ellipsis and the truncation" do
    "123".truncate(3).should == "123"
  end
end
