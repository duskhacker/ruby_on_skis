
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: /Volumes/Projects/wxruby_template/lib/wx/app.xrc 
# Generated at: Sun Apr 19 10:53:44 -0500 2009

class AppFrameBase < Wx::Frame
	
	attr_reader :notebook, :menubar, :file_menu, :quit_menu_item,
              :help_menu, :open, :status_bar
	
	def initialize(parent = nil)
		super()
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load(File.dirname(__FILE__) + '/../app.xrc')
		xml.load_frame_subclass(self, parent, "AppFrame")

		finder = lambda do | x | 
			int_id = Wx::xrcid(x)
			begin
				Wx::Window.find_window_by_id(int_id, self) || int_id
			# Temporary hack to work around regression in 1.9.2; remove
			# begin/rescue clause in later versions
			rescue RuntimeError
				int_id
			end
		end
		
		@notebook = finder.call("notebook")
		@menubar = finder.call("menubar")
		@file_menu = finder.call("file_menu")
		@quit_menu_item = finder.call("quit_menu_item")
		@help_menu = finder.call("help_menu")
		@open = finder.call("Open")
		@status_bar = finder.call("status_bar")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


