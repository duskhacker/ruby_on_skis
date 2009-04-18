require 'mkmf'
require 'fileutils' # ? 

namespace :package do 
  
  desc "Create DMG for App"
  task :dmg, "version" do | t, args |
    raise "No Version specified" if args.version.nil?
    self.build_version = args.version
    Rake::Task['package:osx_app'].invoke(args.version)
    rm_rf dmg_source_name
    mkdir_p dmg_source_name 
    cp_r app_bundle_name, dmg_source_name
    rm_rf dmg_image_name
    sh "hdiutil create -fs HFS+ -srcfolder #{dmg_source_name} -format UDBZ " +
       "-volname '#{Environment.app_name} #{build_version}'  #{dmg_image_name}"
  end

  desc "Create an OSX App bundle"
  task :osx_app, "version" do | task, args |
    raise "No Version specified" if args.version.nil?
    self.build_version = args.version
    assemble
    
    rm_rf app_bundle_name
    generate_osx_shell_wrapper
    
    includes = config[:common][:include_dirs].inject("-f build/bin ") do | inc, dir |
      inc << "-f build/#{dir} "
    end
        
    sh "platypus -a '#{Environment.app_name}' -V #{build_version} " +
       "-f build/lib #{includes}  " + 
       "#{osx_shell_wrapper_name} #{Environment.app_root + '/' + Environment.app_name}.app"

    require 'rexml/document'
    info_plist = File.join(app_bundle_name, 'Contents', 'Info.plist')
    doc = REXML::Document.new( File.read(info_plist) )
    dict = doc.elements['/plist/dict']
    dict_items = dict.children.grep(REXML::Element)
    lsui_key = dict_items.find { | elem | elem.text == 'LSUIElement' }
    lsui_val = dict_items[ dict_items.index( lsui_key ) + 1 ]
    lsui_val.text = '1'

    File.open(info_plist, 'w') { | plist_file | plist_file.write( doc.to_s ) }
  end

  def app_bundle_name
    @app_bundle ||= Environment.app_name + '.app'
  end

  def dmg_source_name 
    @dmg_source_name ||= File.join(Environment.app_root, 'dmg')
  end
  
  def dmg_image_name
    @dmg_image_name ||= ("#{Environment.app_name}-%s.dmg" % build_version)
  end

  def osx_shell_wrapper_name 
    @osx_shell_wrapper_name ||= build_dir + "/init.sh"
  end
  
  def generate_osx_shell_wrapper
    File.open(osx_shell_wrapper_name, 'w') do | f | 
      f.puts "#!/bin/sh\n" + 
      "export DYLD_LIBRARY_PATH=\"$1/Contents/Resources/bin\" && exec" + 
      " \"$1/Contents/Resources/bin/#{app_ruby_executable_name}\" " +
      "-I\"$1/Contents/Resources/config\" " + 
      "\"$1/Contents/Resources/bin/pinit.rb\" \"$1\""
    end
  end
end
