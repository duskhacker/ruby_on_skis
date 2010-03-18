require 'rbconfig'
require 'fileutils'
require 'optparse'
require 'ostruct'
require 'find'

module RubyOnSkis
  class AppGenerator 
    include FileUtils

    attr_reader :options

    def initialize
      @options = OpenStruct.new
      options.source_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'sources'))
    end

    def run
      parse_options
      Dir.chdir options.source_dir
      source_entries =  Find.find(".")
      create_directories(source_entries)
      copy_files(source_entries)
    end

    private
    
    def parse_options
      options.include_active_record = false
      options.include_example_project = false
      parser = OptionParser.new do |opts|
        # opts.on("-a", "--active-record", "Include ActiveRecord Support") do
        #   options.include_active_record = true
        # end
        # 
        # opts.on("-e", "--example", "Include Example Project code (implies '-a')") do
        #   options.checkout_projects = true
        #   options.include_active_record = true
        # end
        # opts.banner = "Usage: rskis [options] /path/to/new_project\n#{opts.summarize.join('')}" 
        opts.banner = "Usage: rskis /path/to/new_project\n#{opts.summarize.join('')}" 
      end
      
      parser.parse!
      abort parser.banner  unless ARGV.size == 1
      options.target_dir = ARGV[0]
    rescue OptionParser::MissingArgument, OptionParser::InvalidOption => e
      $stderr.puts e
      abort parser.banner
    end
    
    def create_directories(entries)
      entries.select{ | s | File.directory?(s)}.each { |path| mkdir_p(File.join(options.target_dir, path)) } 
    end

    def copy_files(entries)
      entries.select{ |s | File.file?(s)}.each{ | file | install file }
    end

    def install(source, target=nil)
      target = target.nil? ? source : target 
      full_target = File.join(options.target_dir, target)
      if File.exists?(full_target)
        print "#{target} exists, overwrite? (y/N) "
        return unless $stdin.gets =~ /y/i
        puts ""
      end
      puts "create #{File.expand_path(File.join(options.target_dir, target))}"
      cp_r( File.join(options.source_dir, source), File.join(options.target_dir, target), :verbose => false)
    end

  end
end
