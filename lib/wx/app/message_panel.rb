# MesagePanelBase will be defined by the XRC generated from
# wxFormBuilder. Use the "Subclass" property in wxFB for the
# panel to define it.
class MessagePanel < MessagePanelBase
  include Helpers
  include Wx
  
  NAME_COL = 0
  DELETE_COL = 1
  
  attr_reader :top_window, :editor, :messages, :message_names, :delete

  def initialize(parent)
    super(parent)

    @top_window = get_app.get_top_window
    
    # wxFormBuilder does not support all widgets. Here is an example of how to 
    # include an unsupported widget. Just define a small wxStaticLine in wxFB, then 
    # use that as the 'handle' to add the widget to the staticline's container.
    
    @editor = StyledTextCtrl.new(self, :style => SUNKEN_BORDER, :border => 10)
    editor.set_wrap_mode 1 
    editor.set_margin_width 1, 30
    editor.set_margin_type 1,1 # Line numbers
    editor.set_zoom(5) if Environment.mswin? 
    staticline.get_containing_sizer.add(editor,1,EXPAND)
    
    evt_button add_button, :on_add_button
    evt_button delete_button, :on_delete_button
    evt_grid_cell_left_click :on_grid_cell_left_click
    evt_grid_cell_left_dclick { | evt |  evt.veto }
    
    init_grid
  end
  
  def delete_col?(column)
    column == DELETE_COL
  end
  
  def on_grid_cell_left_click(evt)
    return unless delete_col?(evt.get_col)
    if record_grid.get_cell_value(evt.get_row, DELETE_COL) == "1"
      record_grid.set_cell_value(evt.get_row, DELETE_COL, "0") 
      delete.delete(evt.get_row)
    else
      record_grid.set_cell_value(evt.get_row, DELETE_COL, "1")
      delete << evt.get_row
    end
  end
  
  def on_add_button
    Message.create!(:name => name_text_ctrl.get_value, :content => editor.get_text)
    record_grid.append_rows(1)
    load_grid
  rescue ActiveRecord::ActiveRecordError => e
    error_alert(e.to_s)
  end
  
  def on_delete_button
    delete.each do | index |
      messages[index].destroy
      record_grid.delete_rows(0,1)
    end
    load_grid
  rescue ActiveRecord::ActiveRecordError =>  e
    error_alert(e.to_s)
  end
  
  def init_grid
    @delete = []
    
    record_grid.create_grid(Message.count, 2 )
    record_grid.set_col_label_value(NAME_COL, "Name")
    record_grid.set_col_label_value(DELETE_COL, "Delete?")
    record_grid.set_col_format_bool(DELETE_COL)
    record_grid.set_default_cell_alignment(-1, ALIGN_CENTRE)

    load_grid
  end
  
  def load_grid
    @messages = Message.ordered_by_name
    @message_names = Message.names
    delete.clear
    record_grid.clear_grid

    message_names.each_with_index do | name, i |
      record_grid.set_cell_value(i, NAME_COL, name.truncate(40))
      record_grid.set_read_only(i, NAME_COL)
      
      record_grid.set_cell_alignment(i, DELETE_COL, ALIGN_CENTRE, ALIGN_TOP)
    end

    record_grid.auto_size
    record_grid.get_containing_sizer.layout
  end
end    
