# Production init. There is some common code with the development-mode 'init.rb', 
# but it's not worth the extra effort to refactor it out, you'll probably hardly 
# ever touch these files.

bundle_path = File.expand_path(File.dirname(__FILE__) + '/../lib' )

$LOAD_PATH.clear
$LOAD_PATH << bundle_path
$LOAD_PATH << File.join(bundle_path, 'ruby', 'site_ruby', RUBY_VERSION)
$LOAD_PATH << File.join(bundle_path, 'ruby', RUBY_VERSION)
$LOAD_PATH << File.join(bundle_path, 'ruby', RUBY_VERSION, RUBY_PLATFORM)
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