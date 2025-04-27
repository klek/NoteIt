class_name Card
extends PanelContainer

# Signal
signal card_clicked( index : int, button : int )

# References
@onready var title_label : TextBox = $MarginContainer/VBoxContainer/Title
@onready var description_label : TextBox = $MarginContainer/VBoxContainer/Description


## Function to set the data of this card
func set_card_data( card_data : CardData ) -> void:
    if ( card_data ):
        title_label.text = card_data.title
        description_label.text = card_data.description
        if ( card_data.wrap_text ):
            # Hardcoded the wrapmode
            description_label.wrap_mode = TextServer.AUTOWRAP_WORD_SMART


## Callback for this card pressed
func _on_gui_input(event: InputEvent) -> void:
    if ( ( event is InputEventMouseButton ) && \
         ( ( event.button_index == MOUSE_BUTTON_LEFT ) || \
           ( event.button_index == MOUSE_BUTTON_RIGHT ) ) && \
         ( event.is_pressed() ) ):
        card_clicked.emit( get_index(), event.button_index )
