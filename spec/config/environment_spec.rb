require File.dirname(__FILE__) + '/../spec_helper'

describe Environment do
  it "should have an data_path method" do
    if Environment.mswin?
      Environment.data_path.should == "#{File.expand_path(ENV['APPDATA'])}/#{Environment.app_name.camelize}"
    elsif Environment.darwin?
      Environment.data_path.should == "#{ENV['HOME']}/.#{Environment.app_name.underscore.downcase}/"
    else
      fail "No test defined for #{RUBY_PLATFORM}"
    end
  end
  
  describe "backup_database" do 
    before :each do
      Environment.environment = "production" 
    end
    
    it "should return the number of backups" do 
      Environment.backup_limit.should == 10
    end
    
    it "should not perform for other than production environments" do
      Environment.environment = "other"
      FileUtils.should_not_receive(:cp)
      Environment.backup_database
    end
    
    it "should attempt to copy the database if it does not exist" do
      File.should_receive(:exists?).with(Environment.db_file).and_return(false)
      FileUtils.should_not_receive(:cp)
      Environment.backup_database
    end
    
    it "should perform for production environments" do
      File.stub!(:exists?).and_return(true)
      FileUtils.should_receive(:cp)
      Environment.backup_database
    end
    
    it "should rename all existing backups with an increment of 1 and delete the backup limit if it exists" do
      File.stub!(:exists?).and_return(true)
      FileUtils.should_receive(:cp).with("#{Environment.db_file}", "#{Environment.db_file}.1")
      backup_files = (1..Environment.backup_limit).collect{ | i | "#{Environment.db_file}.#{i}" }
      Dir.should_receive(:glob).with("#{Environment.db_file}.*").and_return(backup_files)
      (1..Environment.backup_limit).each do | i |
        next if i == Environment.backup_limit
        FileUtils.should_receive(:mv).with("#{Environment.db_file}.#{i}", "#{Environment.db_file}.#{i+1}")
      end
      Environment.backup_database
    end
  end
end
