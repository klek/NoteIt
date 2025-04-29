class_name ColumnInput
extends PanelContainer

signal column_input_accept( table_data : TableData, column_data : ColumnData )

signal column_input_cancel( )

@export var table_data : TableData

@onready var discard_button: Button = %DiscardButton
@onready var title_input: LineEdit = %TitleInput
@onready var index_input: LineEdit = %IndexInput
@onready var accept_button: Button = %AcceptButton
@onready var cancel_button: Button = %CancelButton



func _on_accept_button_pressed() -> void:
    var column_data : ColumnData = ColumnData.new()
    column_data.column_title = title_input.text
    # TODO(klek): Need to process the input for column index!
    column_data.column_index = int ( index_input.text )
    column_input_accept.emit( table_data, column_data )


func _on_cancel_pressed() -> void:
    column_input_cancel.emit( )

#
func _on_visibility_changed() -> void:
    # If we are not visible we set the text input fields to default
    if ( !visible ):
        if ( title_input ):
            title_input.clear()
        if ( index_input ):
            index_input.clear()
