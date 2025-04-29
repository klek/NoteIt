class_name Table
extends PanelContainer

const c_column_scene = preload("res://scenes/column/column.tscn")

signal table_clicked( index : int, button : int, action : TableData.TABLE_ACTIONS )

#@export var test_table_data : TableData

@onready var add_column: Button = %AddColumn
@onready var column_tree: HBoxContainer = %ColumnTree
@onready var title: TextBox = %Title
@onready var grabbed_column: Column = %GrabbedColumn
@onready var grabbed_card: Card = %GrabbedCard
@onready var card_input: CardInput = %CardInput
@onready var column_input: ColumnInput = %ColumnInput

# Internal variables
var grabbed_card_data : CardData
var grabbed_column_data : ColumnData

func _ready() -> void:
    ##populate_table_data( test_table_data )
    #set_table_data( test_table_data )
    # Connect signals for CardInput
    card_input.card_input_accept.connect( _on_card_input_accept )
    card_input.card_input_cancel.connect( _on_card_input_cancel )
    # Connect signals for ColumnInput
    column_input.column_input_accept.connect( _on_column_input_accept )
    column_input.column_input_cancel.connect( _on_column_input_cancel )

#
func _physics_process( _delta: float ) -> void:
    if ( grabbed_card.visible ):
        grabbed_card.global_position = get_global_mouse_position() + Vector2( 5, 5 )
    if ( grabbed_column.visible ):
        grabbed_column.global_position = get_global_mouse_position() + Vector2( 5, 5 )

#
func set_table_data( table_data : TableData ) -> void:
    # Set title of the table
    title.text = table_data.title
    # Connect signals from the table_data to table GUI
    table_data.table_data_interact.connect( _on_table_data_interact )
    table_data.table_data_updated.connect( populate_table_data )
    # Connect signals from the table GUI to table_data
    # NOTE(klek): This is not how it was planned...
    if ( table_data ):
        add_column.pressed.connect( table_data._on_column_add_clicked )
    populate_table_data( table_data )

#
func clear_table_data( table_data : TableData ) -> void:
    table_data.table_data_updated.disconnect( populate_table_data )

#
func populate_table_data( table_data : TableData ) -> void:
    # Clear table
    for child in column_tree.get_children():
        if ( child && child is Column ):
            # Disconnect signals
            child.column_clicked
        child.queue_free()
    # Re-populate based on the table_data
    for column_data in table_data.column_datas:
        var column : Column = c_column_scene.instantiate()
        # TODO(klek): Search for the lowest index
        column_tree.add_child( column )
        # Connect the column clicked signal to the table_data callback
        column.column_clicked.connect( table_data._on_column_clicked )
        # Connect the add card clicked signal to the table_data callback
        #column.add_card_clicked.connect( _on_add_card_clicked )
        # Is the column empty
        if ( column_data ):
            # Connect the individual columns interact signal to the callback
            # in this module
            if ( !column_data.column_data_interact.is_connected( _on_column_data_interact ) ):
                column_data.column_data_interact.connect( _on_column_data_interact )
            column.set_column_data( column_data )

#
func update_grabbed_card() -> void:
    if ( grabbed_card_data ):
        grabbed_card.show()
        grabbed_card.set_card_data( grabbed_card_data )
    else:
        grabbed_card.hide()

#
func update_grabbed_column() -> void:
    if ( grabbed_column_data ):
        grabbed_column.show()
        grabbed_column.set_column_data( grabbed_column_data )
    else:
        grabbed_column.hide()

#
func _on_column_data_interact( column_data : ColumnData, card_index : int, button : int, action : ColumnData.COLUMN_ACTIONS ) -> void:
    # Currently we don't use actions
    #if ( action == ColumnData.COLUMN_ACTIONS.CARD_CLICKED ):
    match [ grabbed_card_data, button ]:
        [ null, MOUSE_BUTTON_LEFT ]:
            grabbed_card_data = column_data.grab_card_data( card_index )
        [ _, MOUSE_BUTTON_LEFT ]:
            # This will never hit, because we don't keep open slots in the array
            grabbed_card_data = column_data.drop_card_data( grabbed_card_data, card_index )
        [ null, MOUSE_BUTTON_RIGHT ]:
            pass
        [ _, MOUSE_BUTTON_RIGHT ]:
            pass
    # Update the GrabbedCard panel
    update_grabbed_card()

#
func _on_table_data_interact( table_data : TableData, column_index : int, button : int, action : TableData.TABLE_ACTIONS ) -> void:
    # Check the action
    match ( action ):
        TableData.TABLE_ACTIONS.COLUMN_CLICKED:
            # Do we currently have a valid card_data?
            match [ grabbed_card_data, button ]:
                [ null, MOUSE_BUTTON_LEFT ]:
                    pass
                [ _, MOUSE_BUTTON_LEFT ]:
                    # The we need to add a slot to the column index we clicked
                    table_data.column_datas[ column_index ].add_card_data( grabbed_card_data )
                    grabbed_card_data = null
                [ null, MOUSE_BUTTON_RIGHT ]:
                    pass
                [ _, MOUSE_BUTTON_RIGHT ]:
                    pass
            # Update the GrabbedCard panel
            update_grabbed_card()
        TableData.TABLE_ACTIONS.COLUMN_GRAB_CLICKED:
            match [ grabbed_column_data, button ]:
                [ null, MOUSE_BUTTON_LEFT ]:
                    #grabbed_column_data = table_data.grab_column_data( column_index )
                    pass
                [ _, MOUSE_BUTTON_LEFT ]:
                    pass
                [ null, MOUSE_BUTTON_RIGHT ]:
                    pass
                [ _, MOUSE_BUTTON_RIGHT ]:
                    pass
            update_grabbed_column()
        TableData.TABLE_ACTIONS.COLUMN_ADD_CLICKED:
            column_input.table_data = table_data
            column_input.show()
        TableData.TABLE_ACTIONS.CARD_ADD_CLICKED:
            # Here we need to collect data via card-input
            card_input.table_data = table_data
            card_input.column_index = column_index
            card_input.show()

#
func _on_column_input_accept( table_data : TableData, column_data : ColumnData ) -> void:
    print( "Column added" )
    table_data.add_column_data( column_data )
    column_input.hide()

#
func _on_column_input_cancel( ) -> void:
    column_input.hide()

#
func _on_card_input_accept( table_data : TableData, column_index : int, card_data : CardData ) -> void:
    # TODO(klek): Setup and show card_input GUI
    # To add a card to a column, we need to know what the columns index in
    # the table_data.column_datas array is
    print( "Card added" )
    table_data.column_datas[ column_index ].add_card_data( card_data )
    card_input.hide()

#
func _on_card_input_cancel( ) -> void:
    card_input.hide()


func _on_gui_input(event: InputEvent) -> void:
    if ( ( event is InputEventMouseButton ) && \
         ( ( event.button_index == MOUSE_BUTTON_LEFT ) || \
           ( event.button_index == MOUSE_BUTTON_RIGHT ) ) && \
         ( event.is_pressed( ) ) ):
        # NOTE(klek): Index is not used here
        table_clicked.emit( 0, event.button_index, TableData.TABLE_ACTIONS.TABLE_CLICKED )
        print( "Clicked table" )
