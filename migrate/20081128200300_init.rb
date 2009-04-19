class Init < ActiveRecord::Migration
  def self.up
    create_table( :messages ) do |t|
      t.string :name
      t.string :content
    end
  end
  

  def self.down
    drop_table :messages
  end
end

