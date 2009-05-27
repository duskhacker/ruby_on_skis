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
      rm_rf( targets ) unless targets.empty?
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
    
    cp File.expand_path(File.join(Environment.app_root, 'bin', 'pinit.rb')), bin_dir

    cp "#{ruby_executable_name}", "#{bin_dir}/#{app_ruby_executable_name}"
    
    config[:common][:include_dirs].each do | dir |
      cp_r "#{Environment.app_root}/#{dir}", build_dir
    end

    (config[:common][:include_files] + include_files).each do | file |
      if file.is_a?(Hash)
        target = "#{build_dir}/#{file[:target]}"
        mkdir_p(target)  unless File.exists?(target)
        cp file[:source], target
      else
        target_dir = "#{build_dir}/#{File.dirname(file)}"
        mkdir_p(target_dir)  unless File.exists?(target_dir)
        cp Environment.app_root + "/#{file}", target_dir
      end
    end
  end

  def copy_source_files_and_libraries
    ENV['ASSEMBLING'] = "true"
    load File.join(Environment.app_root, 'bin', 'init.rb')
    libraries = Set.new
    $LOADED_FEATURES.each do | feature |
      next if feature == "enumerator.so" # Not sure why we have to do this.
      if path = $LOAD_PATH.detect{ | path | File.exists?(File.join(path, feature)) }
        dest_path = File.join(lib_dir, File.dirname(feature)) 
        FileUtils.mkdir_p(dest_path) unless File.exists?(dest_path)
        cp File.join(path,feature), dest_path

        unless feature =~ /\.rb$/
          `otool -L #{File.join(path,feature)}`.grep(/\s+\//).each do  | line | 
            library = line.strip.split(/\s+/)[0] 
            libraries << library if File.exists?(library) 
          end
        end
      else
        raise "Could not find #{feature} in filesystem."
      end
    end
    
    libraries.each do | file | 
      cp file, bin_dir
    end
  end

  def ruby_executable_name
    @ruby_executable_name ||= File.join( Config::CONFIG['bindir'],
      Config::CONFIG['RUBY_INSTALL_NAME'] +
      Config::CONFIG['EXEEXT'] 
    )
  end
  
  def include_files
    config[RUBY_PLATFORM][:include_files]
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
  
  def app_ruby_executable_name
    if @app_ruby_executable_name.nil?
      @app_ruby_executable_name = case RUBY_PLATFORM
      when "i686-darwin9"
        Environment.app_name
      when "i386-mswin32"
        Environment.app_name.underscore + '.exe'
      else
        raise "No app_ruby_exectable_name defined fer #{RUBY_PLATFORM}"
      end
    end
    @app_ruby_executable_name
  end
end