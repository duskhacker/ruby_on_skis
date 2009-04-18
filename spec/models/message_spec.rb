require File.dirname(__FILE__) + '/../spec_helper'

describe Message do

  before(:each) do
    Message.delete_all 
  end

  describe "validations" do
    it "should require content" do
    end
  end
end
