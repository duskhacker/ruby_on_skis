module Environment
  class << self 
 
    attr_accessor :environment # Accessor for testing
    
    # Change this for each application, many settings are 
    # based off of this setting. 
    def app_name
      "RubyOnSkis"
    end
 
    def setup(environment, load_gui_components = true, loading_from_package = false)
      @environment = environment
      $LOAD_PATH << ( app_root + '/config' )
      require_libs(load_gui_components, loading_from_package)
      Dir.mkdir( data_path ) unless File.exists?(data_path)
      backup_database
      establish_connection
      migrate
      load_fixtures
    end
 
    def require_libs(load_gui_components=true, loading_from_package=false)
      require File.join(app_root, 'vendor', 'gems', 'environment') 
      Bundler.require_env
      require 'find'
      Find.find(File.expand_path(File.dirname(__FILE__) + '/../lib')) do | path |
        Find.prune if !File.directory?(path) || File.basename(path).index('.') == 0 
        $LOAD_PATH << path
      end
      
      app_files = Dir.glob( app_root + '/lib/extensions/**/*.rb')
      app_files += Dir.glob( app_root + '/lib/models/*.rb')

      if load_gui_components
        app_files += Dir.glob( "#{base_class_path}/*.rb")
        app_files += Dir.glob( app_root + '/lib/wx/helpers/*.rb')
        app_files += Dir.glob( app_root + '/lib/wx/app/*.rb')
      end

      app_files.each do | file |
        require file.gsub(/#{app_root}\/lib\//, '')
      end
    end
 
    def establish_connection
      unless production?
        ActiveRecord::Base.logger = Logger.new("#{data_path}/#{environment}.log")
        ActiveRecord::Base.logger.level = Logger::DEBUG
      end
      ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database => db_file
      )
    end
 
    def migrate
      if production? 
        ActiveRecord::Migration.verbose=false
        ActiveRecord::Base.logger = Logger.new("#{data_path}/#{environment}.log")
      end

      ActiveRecord::Migrator.migrate(app_root + "/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      ActiveRecord::Base.logger = nil if production? 
    end
 
    def load_fixtures
      fixture_files = Dir.glob(app_root + "/fixtures/*.{yml,csv}")
      return if fixture_files.empty? 
      require 'active_record/fixtures'
      fixture_files.each do |fixture_file|
        klass = File.basename(fixture_file).gsub(/\.yml/,'').titleize.singularize.constantize
        next if klass.count > 0 
        Fixtures.create_fixtures( app_root + '/fixtures', File.basename(fixture_file, '.yml'))    
      end
    end
    
    def load_tasks
      Dir["#{Environment.app_root}/tasks/**/*.rake"].sort.each { |ext| load ext }
    end

    def load_packager
      if mswin?
        load "#{Environment.app_root}/package/mswin.rake"
      elsif darwin?
        load "#{Environment.app_root}/package/osx.rake"
      end
      load "#{Environment.app_root}/package/package_lib.rake"
    end
 
    def db_file(env=environment)
      database_yml = File.join(data_path, 'database.yml')
      db_path = if File.exists?(database_yml)
        YAML.load_file(database_yml)['database_path']
      else
        data_path
      end
      File.join(db_path, "#{app_name.underscore}_#{env}.db")
    end
    
    def xrc_file
      "#{app_root}/lib/wx/app.xrc"
    end
    
    def base_class_path
      "#{app_root}/lib/wx/base"
    end
    
    def app_file
      "#{app_root}/bin/init.rb"
    end
    
    def spec_path
      "#{app_root}/spec"
    end
 
    def app_root
      File.expand_path(File.dirname(__FILE__) + '/../')
    end
 
    def app_env_const
      app_name.upcase + "_ENV"
    end
    
    def have_console?
      open("CONOUT$", "w") {} 
      true 
    rescue SystemCallError 
      false 
    end

    def data_path
      @data_path ||= if mswin?
        File.expand_path(File.join(ENV['APPDATA'].gsub(/\\/,'/'), app_name.camelize))
      else
        "#{ENV['HOME']}/.#{app_name.underscore}/"
      end
    end

    def tmpdir
      if mswin?
        ENV['TMP'] || ENV['TEMP']
      else
        ENV['TMPDIR']
      end
    end
    
    def production? 
      environment == "production"
    end
    
    def development? 
      environment == "development"
    end
    
    def test? 
      environment == "test"
    end
    
    def mswin?
      RUBY_PLATFORM == 'i386-mswin32'
    end
    
    def darwin?
      RUBY_PLATFORM =~ /darwin/
    end
    
    def ruby_platform 
      case RUBY_PLATFORM
      when /darwin/; "darwin"
      when /mswin/; "mswin"
      when /linux/; "linux"
      end
    end
    
    def backup_database
      return unless Environment.production?
      require 'fileutils'
      file_index_matcher = /#{File.basename(Environment.db_file)}\.(\d)$/
      Dir.glob("#{Environment.db_file}.*").sort.reverse.each do | file |
        next if file == "#{Environment.db_file}.#{backup_limit}"
        file_index = file_index_matcher.match(file)[1].to_i
        FileUtils.mv file, "#{Environment.db_file}.#{file_index+1}"
      end
      FileUtils.cp(Environment.db_file, "#{Environment.db_file}.1") if File.exists?(Environment.db_file)
    end
    
    def backup_limit
      10
    end
  end
end
