class MessagePanel < MessagePanelBase
  include Helpers


  def initialize(parent)
    super(parent)

    @top_window = get_app.get_top_window
  end
end    
