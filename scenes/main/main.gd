extends Node

# TODO(klek): Change project to Low-processor mode under Application/run
# TODO(klek): Change renderer to mobile under Rendering/Renderer/Rendering Method
# TODO(klek): Set the get_window().min_size
# TODO(klek): Use _get_drag_data(), _can_drop_data() and _drop_data()?

# TODO(klek): Clean input data in columns by removing empty slots

@export var table_data : TableData : set = _set_table_data

@onready var table: Table = %Table
@onready var cache: Cache = %Cache
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var file_dialog: FileDialog = %FileDialog

func _set_table_data( value : TableData ) -> void:
    table_data = value
    # Call set table
    if ( table && table_data ):
        table.set_table_data( table_data )

func _ready() -> void:
    # Connect signals
    _connect_signals()
    # Before we send in any data to the GUI, we clean int
    #if ( table_data ):
        #for column in table_data.column_datas:
            ## Iterate through every column and remove empty slots

    # Connect signals
    if ( table_data ):
#        var json_string : String = JSON.stringify( table_data, "...." )
#        print( json_string )
        table.set_table_data( table_data )


func _unhandled_input( _event: InputEvent ) -> void:
    # Handle quitting
    if ( Input.is_action_just_pressed("ui_cancel") ):
        get_tree().quit()


func _connect_signals( ) -> void:
    save_button.pressed.connect( _on_save_button_pressed )
    load_button.pressed.connect( _on_load_button_pressed )
    file_dialog.confirmed.connect( _on_file_dialog_confirmed )

func _on_save_button_pressed( ) -> void:
    cache.save_file( table_data )

func _on_load_button_pressed( ) -> void:
    file_dialog.show()
    #table_data = cache.load_file( "res://save_data.json" )

func _on_file_dialog_confirmed( ) -> void:
    # Get the selected file
    table_data = cache.load_file( file_dialog.current_path )
