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