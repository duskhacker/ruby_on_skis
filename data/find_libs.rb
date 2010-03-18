require 'rubygems'
require 'set'
require 'pp'
require 'csv'
require 'wx'
include Wx

def run_depends(feature)
  depends = File.join("C:", "Program Files", "depends", "depends.exe")
  `#{depends} /c /oc:#{depends_out} /f:1 /pa:0 #{feature}`
end

def depends_out
  # @depends_out ||= File.join("V:", "ruby_on_skis", "depends_#{$$}.csv")
  @depends_out ||= File.join(File.dirname(__FILE__), "depends_1736.csv")
end

def find_dynamic_libraries(feature, current_libraries)
  return if feature =~ /\.rb$/
  # run_depends(feature)
  CSV::Reader.parse(File.open(depends_out)) do |row|
    library = row[1].strip
    # libraries << library if File.exists?(library)
    current_libraries << library
  end  
end


libs = Set.new
target = File.join("C:", "ruby-1.8.7-p72", "bin" , "ssleay32.dll")
# target = File.join("C:", "WINDOWS", "system32", "sqlite3.dll")
find_dynamic_libraries(target, libs)
pp libs