class_name Column
extends PanelContainer

const c_card_scene = preload("res://scenes/card/card.tscn")

# Signals
signal column_clicked( index : int, button : int )


@onready var title: TextBox = $MarginContainer/VBoxContainer/Title
@onready var card_tree: VBoxContainer = $MarginContainer/VBoxContainer/CardTree


func set_column_data( column_data : ColumnData ) -> void:
    # Set title
    title.text = column_data.column_title
    # TODO(klek): Set the width
    column_data.column_updated.connect( populate_card_grid )
    populate_card_grid( column_data )


func clear_column_data( column_data : ColumnData ) -> void:
    column_data.column_updated.disconnect( populate_card_grid )


func populate_card_grid( column_data : ColumnData ) -> void:
    # First clear all current children apart from title
    for child in card_tree.get_children():
        child.queue_free()
    # Then re-populate childs
    for card_data in column_data.card_datas:
        # Is this card empty
        # TODO(klek): Re-enabled generating all available cards due to bug with
        # them being hidden otherwise
        #if ( card_data ):
            # Add childs for each card in the column_data
        add_card( column_data, card_data )
    # TODO(klek): Can we do this another way?
    # Finally add a single card slot at the end
    #add_card( column_data, null )


func add_card( column_data : ColumnData, card_data : CardData = null ) -> void:
    var card : Card = c_card_scene.instantiate()
    card_tree.add_child( card )
    # Connect the signals
    card.card_clicked.connect( column_data._on_card_clicked )
    # Set the card based on the card_data
    card.set_card_data( card_data )


func _on_gui_input(event: InputEvent) -> void:
    if ( ( event is InputEventMouseButton ) && \
         ( ( event.button_index == MOUSE_BUTTON_LEFT ) || \
           ( event.button_index == MOUSE_BUTTON_RIGHT ) ) && \
         ( event.is_pressed() ) ):
        column_clicked.emit( get_index(), event.button_index )
        print( "Clicked column" )
