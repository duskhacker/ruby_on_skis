class MyTaskBarIcon < Wx::TaskBarIcon
  include Helpers
  TBMENU_RESTORE = 6000
  TBMENU_CLOSE = 6001
  TBMENU_CHANGE = 6002
  TBMENU_REMOVE = 6003

  def initialize(frame)
    super()

    @frame = frame

    # starting image
    icon = make_icon("#{Environment.app_name.underscore}.ico")
    set_icon(icon, "#{Environment.app_name}")
    @image_index = 1

    # events
    evt_taskbar_left_dclick  {|evt| on_taskbar_activate(evt) }
    
    evt_menu(TBMENU_RESTORE) {|evt| on_taskbar_activate(evt) }
    evt_menu(TBMENU_CLOSE)   { @frame.close }
    evt_menu(TBMENU_CHANGE)  {|evt| on_taskbar_change(evt) }
    evt_menu(TBMENU_REMOVE)  { remove_icon }
  end
end
