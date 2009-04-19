
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: /Volumes/Projects/wxruby_template/lib/wx/app.xrc 
# Generated at: Sun Apr 19 10:53:44 -0500 2009

class MessagePanelBase < Wx::Panel
	
	attr_reader :name_label, :name_text_ctrl, :add_button, :staticline,
              :record_grid, :delete_button
	
	def initialize(parent = nil)
		super()
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load(File.dirname(__FILE__) + '/../app.xrc')
		xml.load_panel_subclass(self, parent, "MessagePanel")

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
		
		@name_label = finder.call("name_label")
		@name_text_ctrl = finder.call("name_text_ctrl")
		@add_button = finder.call("add_button")
		@staticline = finder.call("staticline")
		@record_grid = finder.call("record_grid")
		@delete_button = finder.call("delete_button")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


