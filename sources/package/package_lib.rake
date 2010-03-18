require 'mkmf'
require 'fileutils' # ?
require 'set'
require 'yaml'
namespace :package do 

  desc "Clean up build products."
  task :clean do 
    [ "*.dmg", '*.app', 'build', 'mkmf.log', 'dmg', 'package/*.exe' ].each do | product |
      targets =  Dir.glob( "#{Environment.app_root}/#{product}" )
      FileUtils.rm_rf( targets ) unless targets.empty?
    end
  end

  def config
    @config ||= YAML.load_file(Environment.app_root + '/package/config.yml')
  end

  def assemble
    rm_rf build_dir
    mkdir build_dir
    mkdir bin_dir
    mkdir lib_dir

    cp File.expand_path(File.join(Environment.app_root, 'bin', 'pinit.rb')), bin_dir, :preserve => true

    cp "#{ruby_executable_name}", "#{bin_dir}/#{app_ruby_executable_name}", :preserve => true
    chmod 0555, "#{bin_dir}/#{app_ruby_executable_name}"

    config[:common][:include_dirs].each do | dir |
      cp_r "#{Environment.app_root}/#{dir}", build_dir, :preserve => true
    end

    config[:common][:include_files].each do | file |
      cp "#{Environment.app_root}/#{file}", build_dir, :preserve => true
    end

    cp_r RbConfig::CONFIG['libdir'], build_dir
    copy_dynamic_libraries

  end
  
  def copy_dynamic_libraries
    require 'find'
    libraries = Set.new 

    Find.find(build_dir) do | path |
      next unless path =~ /\.bundle$/ 
      `otool -L #{path}`.split("\n").each do | line |
        library = line.strip.split(/\s+/).first
        libraries << library if File.exists?(library)
      end
    end

    libraries.each { |file| cp file, bin_dir, :preserve => true }
  end

  def platform_specific_include_files
    if config.has_key?(Environment.ruby_platform) && config[Environment.ruby_platform].has_key?(:include_files) && !config[Environment.ruby_platform][:include_files].nil? 
      config[Environment.ruby_platform][:include_files]
    else 
      []
    end
  end

  def common_include_files
    if config.has_key?(:common) && config[:common].has_key?(:include_files) && !config[:common][:include_files].nil? 
      config[:common][:include_files] 
    else 
      []
    end
  end

  def include_libs
    config[Environment.ruby_platform][:include_libs]
  end

  def build_dir
    @build_dir ||= Environment.app_root + '/build'
  end

  def bin_dir
    @bin_dir ||= "#{build_dir}/bin"
  end

  def lib_dir
    @lib_dir ||= "#{build_dir}/lib"
  end

  def build_version
    raise "No build_version specified" if @build_version.nil?
    @build_version
  end

  def build_version=(version)
    @build_version = version
  end
end
