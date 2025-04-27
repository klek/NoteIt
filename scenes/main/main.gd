extends Node

# TODO(klek): Change project to Low-processor mode under Application/run
# TODO(klek): Change renderer to mobile under Rendering/Renderer/Rendering Method
# TODO(klek): Set the get_window().min_size
# TODO(klek): Use _get_drag_data(), _can_drop_data() and _drop_data()?
# TODO(klek): Clean input data in columns by removing empty slots
# TODO(klek): Add a welcome screen

# References
@onready var table: Table = %Table
@onready var cache: Cache = %Cache
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var file_open: FileDialog = %FileOpen
@onready var file_save: FileDialog = %FileSave

# Internal variables
# TODO(klek): Can we remove the new here?
var _table_data : TableData = TableData.new()

#
func _ready() -> void:
    # Connect signals
    _connect_signals()
    # Connect signals
    if ( _table_data ):
        table.set_table_data( _table_data )

# Handle input, currently only supporting ESC for close
func _unhandled_input( _event: InputEvent ) -> void:
    # Handle quitting
    if ( Input.is_action_just_pressed("ui_cancel") ):
        get_tree().quit()

# Connect signals between the different GUI-elements and data-nodes
func _connect_signals( ) -> void:
    # Setup the cache and its signals
    cache.cached_table_updated.connect( _update_table_data_from_cache )
    cache.filepath_used.connect( _on_file_path_used )
    cache.request_save_file.connect( _on_request_save_file )
    # Setup table and its signals
    _table_data.table_updated.connect( cache.update_cached_table )
    # Setup buttons
    save_button.pressed.connect( _on_save_button_pressed )
    load_button.pressed.connect( _on_load_button_pressed )
    # Setup the file_open
    file_open.confirmed.connect( _on_file_open_confirmed )
    file_open.file_selected.connect( _on_file_open_selected )
    # Setup the file_save
    file_save.canceled.connect( _on_file_save_cancelled )

# Callback-function to update the local table_data based on the cache
func _update_table_data_from_cache( table_data : TableData, cleared : bool = false ) -> void:
    # Was the table cleared?
    if ( cleared ):
        if ( table_data != null ):
            print("Cleared was announced but table is not null?")
        _table_data = null
    if ( table_data != null ):
        _table_data = table_data.duplicate()
    # Call set table
    if ( table && _table_data ):
        table.set_table_data( _table_data )

# Callback for the use of filepath in cache.
# NOTE(klek): This is mostly for debugging currently
func _on_file_path_used( filePath : String, action : Cache.FILE_PATH_ACTION ) -> void:
    match action:
        Cache.FILE_PATH_ACTION.SET:
            print( "Set filepath to: %s" % filePath )
        Cache.FILE_PATH_ACTION.OPENED:
            print( "Open file at filepath: %s" % filePath )
        Cache.FILE_PATH_ACTION.SAVED:
            print( "Saved file to: %s" % filePath )
        _:
            pass

# Callback for the request_save_file from cache-node
func _on_request_save_file( ) -> void:
    file_save.show()

# Callback for the save button. This invokes the cache-functionality for
# save-file
func _on_save_button_pressed( ) -> void:
    cache.save_to_file( )

# Callback for the load button. This invokes the FileOpen file-dialog
func _on_load_button_pressed( ) -> void:
    file_open.show()
    #table_data = cache.load_file( "res://save_data.json" )

# Callback for the confirmed-signal from FileOpen file-dialog
# NOTE(klek): Consider removing this and instead only use the file_selected
func _on_file_open_confirmed( ) -> void:
    # Get the selected file
    cache.load_from_file( file_open.current_path )

# Callback for the file_selected signal from FileOpen file-dialog
func _on_file_open_selected( path : String ) -> void:
    cache.cached_filepath = path

# Callback for the cancelled signal from the FileSave file-dialog
func _on_file_save_cancelled( ) -> void:
    cache.clear_cached_table( )

# Callback for the confirmed-signal from FileSave file-dialog
# NOTE(klek): Consider removing this and instead only use the file_selected
func _on_file_save_confirmed( ) -> void:
    # Get the selected file
    cache.save_to_file( file_open.current_path )

# Callback for the file_selected signal from FileSave file-dialog
func _on_file_save_selected( path : String ) -> void:
    cache.cached_filepath = path
