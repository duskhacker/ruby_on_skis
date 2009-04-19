# MesagePanel Base will be defined by the XRC generated from
# wxFormBuilder. Use the "Subclass" property in wxFB to define
# it.
class MessagePanel < MessagePanelBase
  include Helpers


  def initialize(parent)
    super(parent)

    @top_window = get_app.get_top_window
  end
end    
