require File.dirname(__FILE__) + '/../spec_helper'

describe Message do

  attr_reader :xena
  
  before(:each) do
    Message.delete_all
    @xena = Message.create!(:name => "XenaWarriorPrincess", :content => "some content")
  end

  describe "validations" do 
    it "should require a name" do
      lambda {
        Message.create!(:content => "some content")
      }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end

    it "should require content" do
      lambda {
        Message.create!(:name => "A Name")
      }.should raise_error(ActiveRecord::RecordInvalid, "Validation failed: Content can't be blank")
    end
  end
  
  describe "Accessors" do
    describe "ordered_by_name" do
      it "should return all users, ordered case-insensitively" do
        abby = Message.create!(:name => "abigail", :content => "some content" )

        Message.ordered_by_name.should == [abby, xena]
      end
    end

    describe "names" do
      it "should return a list of names ordered case-insensitively" do 
        abby = Message.create!(:name => "abigail", :content => "Some Content")

        Message.names.should == ["abigail", "XenaWarriorPrincess"]
      end
    end
  end
end
