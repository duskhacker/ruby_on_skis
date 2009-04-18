bundle_path = File.expand_path(File.dirname(__FILE__) + '/../lib' )

$LOAD_PATH.clear
$LOAD_PATH << "#{bundle_path}"
Dir.glob("#{bundle_path}/*") do | path |
  if File.directory?(path)
    $LOAD_PATH << path
  end
end

require 'environment'
env = ENV[Environment.app_env_const] || 'production'
Environment.setup(env, true, true)
title = Environment.app_name.camelize
title << " (#{ENV[Environment.app_env_const].upcase})" unless env == 'production'

unless  ENV['ASSEMBLING'] ==  "true"
  Wx::App.run do 
    self.app_name = title
    @frame = AppFrame.new(title)
    @frame.show
  end
end