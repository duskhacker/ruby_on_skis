require File.dirname(__FILE__) + '/../config/environment'
Environment.setup('test', false)
$:.unshift("/opt/local/lib/ruby/gems/1.8/gems/rspec-1.1.11/lib")
require 'spec'

def putsh(stuff=nil)
  puts "#{ERB::Util.h(stuff.to_s)}<br/>"
end

def ph(stuff=nil)
  putsh stuff.inspect
end

