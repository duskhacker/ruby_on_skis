require 'mkmf'
require 'fileutils' # ?
require 'set'
namespace :package do 

  desc "Zip the project, with version."
  task :zip, :version do | t, args |
    if args.version.nil? 
      puts "usage: rake zip[version]"
      exit 1
    end
    sh "zip -lry #{File.expand_path(Environment.app_root + '/..')}/#{Environment.app_name.downcase}-#{args.version}.zip #{Environment.app_root}"
  end

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

    copy_source_files_and_libraries

    cp File.expand_path(File.join(Environment.app_root, 'bin', 'pinit.rb')), bin_dir, :preserve => true

    cp "#{ruby_executable_name}", "#{bin_dir}/#{app_ruby_executable_name}", :preserve => true
    chmod 0555, "#{bin_dir}/#{app_ruby_executable_name}"

    config[:common][:include_dirs].each do | dir |
      cp_r "#{Environment.app_root}/#{dir}", build_dir, :preserve => true
    end

    (platform_specific_include_files + common_include_files).each do | file |
      if file.is_a?(Hash)
        target = "#{build_dir}/#{file[:target]}"
        mkdir_p(target)  unless File.exists?(target)
        cp file[:source], target, :preserve => true
      else
        target_dir = "#{build_dir}/#{File.dirname(file)}"
        mkdir_p(target_dir)  unless File.exists?(target_dir)
        cp Environment.app_root + "/#{file}", target_dir, :preserve => true
      end
    end
  end

  def copy_source_files_and_libraries
    ENV['ASSEMBLING'] = "true"
    load File.join(Environment.app_root, 'bin', 'init.rb')
    libraries = Set.new
    re = /^.*\/(lib|config)\/(.*)$/
    $LOADED_FEATURES.each do | feature |
      next if feature == "enumerator.so" # Not sure why we have to do this.
      dest_path = File.join(lib_dir, re.match(feature)[2])
      if File.exists?(feature)
        mkdir_p File.dirname(dest_path) unless File.exists?(File.dirname(dest_path))
        cp feature, dest_path, :preserve => true
        find_dynamic_libraries(feature, libraries)
      else
        raise "Could not find #{feature} in filesystem."
      end
    end

    libraries.each { |file| cp file, bin_dir, :preserve => true }
  end

  def platform_specific_include_files
    if config.has_key?(RUBY_PLATFORM) && config[RUBY_PLATFORM].has_key?(:include_files) && !config[RUBY_PLATFORM][:include_files].nil? 
      config[RUBY_PLATFORM][:include_files]
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
    config[RUBY_PLATFORM][:include_libs]
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