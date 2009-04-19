module AppHelper
  include Wx

  def error_alert(message)
    alert(message, "Error")
  end

  def success_alert(message)
    alert(message, "Success")
  end
  
  def alert(message, title)
    @top_window ||= get_app.get_top_window
    alert = MessageDialog.new(@top_window, message, title, OK )
    alert.show_modal
  end
  
  def confirm(message)
    confirm = Wx::MessageDialog.new(parent, message, "Confirm")
    confirm.show_modal == ID_OK
  end

  def new_id
    @int ||= 1000
    @int +=1 
  end

  def make_icon(imgname)
    # Different platforms have different requirements for the
    #  taskbar icon size
    filename = "#{Environment.app_root}/images/#{imgname}" 
    img = Wx::Image.new(filename)
    if Wx::PLATFORM == "WXMSW"
      img = img.scale(16, 16)
    elsif Wx::PLATFORM == "WXGTK"
      img = img.scale(22, 22)
    elsif Wx::PLATFORM == "WXMAC"
      # img = img.scale(16, 16)
    end
    # WXMAC can be any size up to 128x128, so don't scale
    icon = Wx::Icon.new
    icon.copy_from_bitmap(Wx::Bitmap.new(img))
    return icon
  end

  def status_bar_reset(message="")
    status_bar_update(message)
    get_status_bar.set_background_colour NULL_COLOUR
  end
  
  def status_bar_success(message)
    status_bar_update(message)
    get_status_bar.set_background_colour GREEN
  end

  def status_bar_warning(message)
    status_bar_update(message)
    get_status_bar.set_background_colour YELLOW
  end
  
  def status_bar_error(message)
    status_bar_update(message)
    get_status_bar.set_background_colour RED
  end
  
  def status_bar_update(message)
    get_status_bar.status_text =  message
  end
  
  def get_status_bar
    @status_bar ||= get_app.get_top_window.status_bar
  end
  
  def open_command(target)
    open_command = if Environment.darwin?
      "open"
    elsif Environment.mswin?
      "start"
    else
      raise "No open command defined for #{RUBY_PLATFORM}"
    end  
    Thread.new do 
      system("#{open_command} #{target}")
    end
  end
end