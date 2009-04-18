require File.dirname(__FILE__) + '/../../spec_helper'

describe Extensions::String::Truncate do
  it "should leave strings of less than 20 unchanged" do
    "test".truncate.should == "test"
  end
  
  it "should truncate strings of more than 20 chars by default" do
    'City_of_Paris_Combined_Stuff_And_Other'.truncate.should == "City_of_Paris_Com..."
  end

  it "should take an argument to determine the length of the truncation" do
    'City_of_Paris_Combined_Stuff_And_Other'.truncate(30).should == "City_of_Paris_Combined_Stuf..."
  end
  
  it "should return the original string if the truncation size is less than the size of the ellipses" do
    "test".truncate(1).truncate.should == "test"
  end
  
  it "should return the original string if the size of the string would be exactly the same with the ellipsis and the truncation" do
    "123".truncate(3).should == "123"
  end
end
