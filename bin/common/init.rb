# Development init. There is some common code with the production-mode 'pinit.rb', 
# but it's not worth the extra effort to refactor it out, you'll probably hardly 
# ever touch these files.

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../../config')
require 'environment'
env = ENV[Environment.app_env_const] || 'production'
Environment.setup(env)
title = Environment.app_name.camelize
title << " (#{ENV[Environment.app_env_const].upcase})" unless env == 'production'

unless  ENV['ASSEMBLING'] ==  "true"
  Wx::App.run do 
    self.app_name = title
    @frame = AppFrame.new(title)
    @frame.show
  end
end