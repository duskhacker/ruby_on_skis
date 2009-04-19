class Message < ActiveRecord::Base
  validates_presence_of :name, :content
  validates_uniqueness_of :name
  
  named_scope :ordered_by_name, :order => "name COLLATE NOCASE"
  
  def self.names
    connection.select_values("SELECT name FROM messages ORDER BY name COLLATE NOCASE")
  end
  
end