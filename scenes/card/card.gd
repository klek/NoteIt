class_name Card
extends PanelContainer

# Signal
signal card_clicked( index : int, action : CardData.CARD_ACTIONS, button : int )

# References
@onready var title_label : TextBox = %Title
@onready var description_label : TextBox = %Description


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
        card_clicked.emit( get_index(), CardData.CARD_ACTIONS.CARD_CLICKED, event.button_index )

## Callback for the RemoveCardButton pressed
func _on_remove_card_button_pressed() -> void:
    card_clicked.emit( get_index(), CardData.CARD_ACTIONS.CARD_REMOVE_CLICKED, 0 )
