class_name Table
extends PanelContainer

const c_column_scene = preload("res://scenes/column/column.tscn")

#@export var test_table_data : TableData

@onready var column_tree: HBoxContainer = $MarginContainer/VBoxContainer/ColumnTree
@onready var title: TextBox = $MarginContainer/VBoxContainer/Title
@onready var grabbed_column: Column = $GrabbedColumn
@onready var grabbed_card: Card = $GrabbedCard

# Internal variables
var grabbed_card_data : CardData
var grabbed_column_data : ColumnData

#func _ready() -> void:
    ##populate_table_data( test_table_data )
    #set_table_data( test_table_data )


func _physics_process( _delta: float ) -> void:
    if ( grabbed_card.visible ):
        grabbed_card.global_position = get_global_mouse_position() + Vector2( 5, 5 )
    if ( grabbed_column.visible ):
        grabbed_column.global_position = get_global_mouse_position() + Vector2( 5, 5 )


func set_table_data( table_data : TableData ) -> void:
    # Set title of the table
    title.text = table_data.title
    table_data.table_interact.connect( _on_table_interact )
    table_data.table_updated.connect( populate_table_data )
    populate_table_data( table_data )


func clear_table_data( table_data : TableData ) -> void:
    table_data.table_updated.disconnect( populate_table_data )


func populate_table_data( table_data : TableData ) -> void:
    # Clear table
    for child in column_tree.get_children():
        child.queue_free()
    # Re-populate based on the table_data
    for column_data in table_data.column_datas:
        var column : Column = c_column_scene.instantiate()
        # TODO(klek): Search for the lowest index
        column_tree.add_child( column )
        # Connect the column clicked signal to the table_data callback
        column.column_clicked.connect( table_data._on_column_clicked )
        # Is the column empty
        if ( column_data ):
            # Connect the individual columns interact signal to the callback
            # in this module
            column_data.column_interact.connect( _on_column_interact )
            column.set_column_data( column_data )


func update_grabbed_card() -> void:
    if ( grabbed_card_data ):
        grabbed_card.show()
        grabbed_card.set_card_data( grabbed_card_data )
    else:
        grabbed_card.hide()


func update_grabbed_column() -> void:
    if ( grabbed_column_data ):
        grabbed_column.show()
        grabbed_column.set_column_data( grabbed_column_data )
    else:
        grabbed_column.hide()


func _on_column_interact( column_data : ColumnData, index : int, button : int ) -> void:
    match [ grabbed_card_data, button ]:
        [ null, MOUSE_BUTTON_LEFT ]:
            grabbed_card_data = column_data.grab_card_data( index )
        [ _, MOUSE_BUTTON_LEFT ]:
            grabbed_card_data = column_data.drop_card_data( grabbed_card_data, index )
        [ null, MOUSE_BUTTON_RIGHT ]:
            pass
        [ _, MOUSE_BUTTON_RIGHT ]:
            pass
    # Update the GrabbedCard panel
    update_grabbed_card()


func _on_table_interact( table_data : TableData, index : int, button : int ) -> void:
    # Do we currently have a valid card_data?
    match [ grabbed_card_data, button ]:
        [ null, MOUSE_BUTTON_LEFT ]:
            pass
        [ _, MOUSE_BUTTON_LEFT ]:
            # The we need to add a slot to the column index we clicked
            table_data.column_datas[ index ].add_card_data( grabbed_card_data )
            grabbed_card_data = null
        [ null, MOUSE_BUTTON_RIGHT ]:
            pass
        [ _, MOUSE_BUTTON_RIGHT ]:
            pass
    # Update the GrabbedCard panel
    update_grabbed_card()
