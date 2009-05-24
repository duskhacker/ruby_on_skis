require 'rake'
require 'spec/rake/spectask'
require 'logger'

config_path = File.expand_path(File.dirname(__FILE__) + '/config')
$LOAD_PATH << config_path unless $LOAD_PATH.include?(config_path)
require 'environment'
Environment.load_tasks

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList["#{Environment.spec_path}/**/*_spec.rb"]
  t.spec_opts = ['--options', "#{Environment.spec_path}/spec.opts"]
end

desc "Run Project"
task :run => Environment.base_class_path do
  ENV[Environment.app_env_const] = 'development'
  executable = File.join( Config::CONFIG['bindir'],
                          Config::CONFIG['RUBY_INSTALL_NAME'] +
                          Config::CONFIG['EXEEXT'] )
  exec("#{executable} #{Environment.app_file}")
end

desc "Generate Wx Base Classes from XRC"
file Environment.base_class_path => Environment.xrc_file do | t |
  $stderr.puts "Generating GUI Base Classes"
  sh "xrcise -o #{Environment.base_class_path} #{Environment.xrc_file} && touch #{Environment.base_class_path}"
  make_bases_relative
end

def make_bases_relative
  Dir.glob(Environment.base_class_path + '/*.rb') do | file |
    fh = File.open(file, "r+") 
    data = fh.readlines
    data.each do | line |
      line.gsub! /"#{Environment.xrc_file}"/, "File.dirname(__FILE__) + '/../app.xrc'"
    end
    fh.rewind
    fh.truncate(0)
    fh.puts data
    fh.close
  end
end

task :default  => :spec
