class_name CardInput
extends PanelContainer

signal card_input_accept( table_data : TableData, column_index : int, card_data : CardData )

signal card_input_cancel( )

@export var extent : Vector2 = Vector2( 400.0, 200.0 ) : set = _set_extent

@export var table_data : TableData
@export var column_index : int

# Reference
@onready var title_input: LineEdit = %TitleInput
@onready var description_input: TextEdit = %DescriptionInput
@onready var accept_button: Button = %AcceptButton
@onready var cancel_button: Button = %CancelButton

# Internal variables
#var _title : String
#var _description : String

# Set function for the extent of this window
func _set_extent( value : Vector2 ) -> void:
    extent = value
    #size = extent
    #queue_redraw()


func _on_accept_button_pressed() -> void:
    # Get the data from both the title and the description
    var card_data : CardData = CardData.new()
    card_data.title = title_input.text
    card_data.description = description_input.text
    # Then we emit this
    card_input_accept.emit( table_data, column_index, card_data )


func _on_cancel_pressed() -> void:
    card_input_cancel.emit( )


func _on_visibility_changed() -> void:
    # If we are not visible we set the text input fields to default
    if ( !visible ):
        if ( title_input ):
            title_input.clear()
        if ( description_input ):
            description_input.clear()
