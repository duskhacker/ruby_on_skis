require 'mkmf'
require 'fileutils' #?

namespace :package do 
  desc "Create NSIS installer"
  task :mswin, "version"  do |t, args|
    raise "No Version specified" if args.version.nil?
    self.build_version = args.version
    assemble
    
    generate_mswin_shell_wrappers
    touch "#{bin_dir}/ubygems.rb" # For dumb RUBYOPTS
    puts `#{makensis} /V1 /DAPP_NAME=#{Environment.app_name} /DAPP_NAME_DOWNCASE=#{Environment.app_name.downcase} /DAPP_DOC_EXTENSION=#{app_doc_extension} /DVERSION=#{build_version} /DVERSIONEXTRA=#{build_version + ".0.0"} /DBUILD_DIR=#{build_dir} #{nsis_scriptfile_name}`
  end
  
  def app_doc_extension
    '.dtt'
  end
  # Needed to give XP-style widgets
  def manifest_file_name
    File.join(build_dir, "#{Environment.app_name.downcase}.exe.manifest")
  end

  def generate_manifest_file
    File.open(manifest_file_name, 'w') do | f |
      f.puts("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
  <assembly xmlns=\"urn:schemas-microsoft-com:asm.v1\" manifestVersion=\"1.0\"><assemblyIdentity version=\"1.8.6.0\" processorArchitecture=\"X86\" name=\"Microsoft.Winweb.Ruby\" type=\"win32\" /><description>#{Environment.app_name} Ruby Interpreter</description><dependency><dependentAssembly><assemblyIdentity type=\"win32\" name=\"Microsoft.Windows.Common-Controls\" version=\"6.0.0.0\" processorArchitecture=\"X86\" publicKeyToken=\"6595b64144ccf1df\" language=\"*\"  /></dependentAssembly></dependency></assembly>")
    end
  end

  def nsis_scriptfile_name
     File.join(Environment.app_root, "/package/installer.nsi")
  end

  def makensis
    config["i386-mswin32"][:makensis]
  end

  def nsis_outfile
    "#{Environment.app_name.downcase}-install-#{build_version}.exe"
  end
  
  # The craziness below is solely for the purpose of 
  # unsetting RUBYOPT, which can disable the program if not 
  # set correctly. Better solutions are welcome
  def generate_mswin_shell_wrappers
    File.open(bin_dir + "/init.bat", 'w') do | f | 
      f.puts "set RUBYOPT=\n" + 
      "#{app_ruby_executable_name} pinit.rb\n"
    end

    File.open(bin_dir + "/run.vbs", 'w') do | f | 
      f.puts "Set WshShell = CreateObject(\"WScript.Shell\")\n" + 
        "WshShell.Run chr(34) & \"init.bat\" & Chr(34), 0\n" + 
      "Set WshShell = Nothing\n"
    end
  end
  
  def ruby_bin_dir
    config[RUBY_PLATFORM][:ruby_bin_dir]
  end
end