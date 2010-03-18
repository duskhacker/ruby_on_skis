# AppFrameBase will be defined by the XRC generated from
# wxFormBuilder. Use the "Subclass" property in wxFB to define
# it.
class AppFrame < AppFrameBase
  include AppHelper
  
  def initialize(title)
    super()

    if Environment.darwin?
      @tbicon = MyTaskBarIcon.new(self)
    elsif Environment.mswin?
      icon_file = File.join(Environment.app_root, 'images', "#{Environment.app_name.underscore}.ico")
      icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_ICO)
      set_icon(icon)
    end

    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about

    evt_menu quit_menu_item, :on_quit
    
    self.title = title 
    self.size = [ 1024, 868 ]

    self.status_text = "Welcome to #{Environment.app_name}!"
    status_bar.set_min_height 80

    # The apps I've written so far are single window affairs with several notebook pages. wxFormBuilder doesn't seem to 
    # support this directly, so creating an AppFrame, and then the notebook pages as separate panels, and tying them together
    # here seems to work well. 
    message_panel = MessagePanel.new(notebook)
    notebook.add_page(message_panel, "Messages")
  end
  
  def on_quit
    @tbicon.remove_icon unless @tbicon.nil?
    destroy()
    exit()
  end

  # show an 'About' dialog
  def on_about
    # TODO: Make version dynamic somehow.
    msg =  sprintf("Welcome to #{Environment.app_name}, version 0.1")

    # create a simple message dialog with OK button
    about_dlg = Wx::MessageDialog.new( self, msg, "About #{Environment.app_name}",
    Wx::OK|Wx::ICON_INFORMATION )
    about_dlg.show_modal
  end
end
# icon_file = File.join( File.dirname(__FILE__), "mondrian.png")
# # PNG can be used on all platforms, but icon type must be specified
# # to work on Windows; OS X doesn't have "Frame" icons.
# self.icon = Wx::Icon.new(icon_file, Wx::BITMAP_TYPE_PNG)
