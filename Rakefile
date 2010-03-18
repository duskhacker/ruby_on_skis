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

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "ruby_on_skis"
    gemspec.summary = "Provide a starting structure within which to program your wxRuby project"
    gemspec.description = <<-DESCRIPTION
    
      I've just created the gem, which is totally non-working. Please do not install. 
      I've just pushed it to get a feel for what to do. 
    
      The aim of Ruby on Skis is to provide a starting structure within which to program your wxRuby project. 
      The template provides a directory structure, a set of Rakefiles to manage, and most importantly, to 
      package your Ruby application for distribution as a standalone program when completed. It also includes 
      an environment to get the application running and provide basic services to the program code. 
      For now, the template only supports packaging for Mac OSX and Windows, although various flavors of 
      Linux should be easily accommodated and are planned for the future    
    DESCRIPTION
    gemspec.email = "duskhacker@duskhacker.com"
    gemspec.homepage = "http://github.com/duskhacker/ruby_on_skis"
    gemspec.authors = ["Daniel P. Zepeda"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
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
