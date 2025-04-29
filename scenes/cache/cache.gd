class_name Cache
extends Node

## Enumeration to define file-actions for the signal filepath_used
enum FILE_PATH_ACTION {
    SET,
    OPENED,
    SAVED,

    UNDEF
}

# Signals
## Signal emitted when the cached table is updated
## This should be used to update the GUI
signal cached_table_updated( table_data : TableData, cleared : bool )

## Signal used for filepath changes and uses
signal filepath_used( filePath : String, action : FILE_PATH_ACTION )

## Signal used to request a save file
# NOTE(klek): Could potentially use this with filepath_used and actions?
signal request_save_file()

## Variable to store the currently cached table
@export var cached_table : TableData : set = _set_table, get = _get_table

## Variable to store the currently cached filepath
@export var cached_filepath : String = "" : set = _set_file_path, get = _get_file_path

# Internal variables
# Variable to store all previously cached tables, since last clear
# Clears happen on file-load or if the cached table is set to an empty
# table
# TODO(klek): Use this for undo action
var _cached_tables : Array[ TableData ]

# Set function for the cached_table
# NOTE(klek): The cached table should always have a valid table
func _set_table( value : TableData ) -> void:
    # Check if the value is null
    if ( value == null || value.is_empty() ):
        # Then we clear the cached data
        _cached_tables.clear()
        cached_table = TableData.new()
        _cached_tables.push_back( cached_table )
        # Emit the update
        cached_table_updated.emit( cached_table, true )
    else:
        # Add the newest table to the array
        _cached_tables.push_back( value.duplicate() )
        cached_table = value
        # Emit the update
        cached_table_updated.emit( cached_table, false )

# Get function for cached_table
func _get_table( ) -> TableData:
    return cached_table

# Set function for cached_filepath
func _set_file_path( value : String ) -> void:
    # NOTE(klek): Do we need to check something here?
    cached_filepath = value
    filepath_used.emit( cached_filepath, FILE_PATH_ACTION.SET )

# Get function for cached_filepath
func _get_file_path( ) -> String:
    return cached_filepath

# This function tries to save the currently cached table to the path
# provided. If a path is not provided, it tries to save to the cached
# filepath.
# If there is no cached filepath, this function emits a request for
# a filepath and returns
# If the data was saved, the signal for filepath used will be emitted
# with the save action
func save_to_file( filePath : String = "" ) -> void:
    # If we don't have a cached filepath we need to prompt the user
    # about a filepath
    # If we got a filepath, we prioritize that one
    if ( !filePath.is_empty() ):
        cached_filepath = filePath
    # Otherwise we use the cache filepath
    elif ( cached_filepath.is_empty() ):
        # If this is empty, well we are in a pickle...
        # Prompt user about a save location / filepath
        request_save_file.emit()
        print( "Need a path to save to!" )
        # And then we return here
        return
    # Otherwise, lets continue to open the provide path
    var file : = FileAccess.open( cached_filepath, FileAccess.WRITE )
    if ( file ):
        # NOTE(klek): Do we need to check if the file is empty? Or do we just
        # overwrite it?
        var data_to_save : Dictionary
        # Check that the cached_table is valid and not empty
        if ( cached_table != null && !cached_table.is_empty() ):
            # The write data to the dictionary
            data_to_save = cached_table.convert_to_dict()
        # Otherwise we just write an empty dictionary
        # Write the dictionary to file
        file.store_string( JSON.stringify( data_to_save, "\t" ) )
        file.close()
        # TODO(klek): We should show a small popup here of successfull save
        filepath_used.emit( cached_filepath, FILE_PATH_ACTION.SAVED )
    else:
        print( "Could not open save-file: %s" % cached_filepath )

# This function is used to load a table from file. It tries to load a
# table from the provided path.
# If there is already a cached table that is not empty, this function
# will emit a signal to request a save-file.
# If the file was loaded successfully and contains a table, the cached
# table will be updated to this and return
# NOTE(klek): Successfully loading from file, will reset the cached table
# history
func load_from_file( filePath : String ) -> TableData:
    # Check if the filePath provided is different from the cached file
    if ( filePath != cached_filepath ):
        # Then we have a changed filepath that we are trying to load.
        # If the cached table is empty, this is no problem, but if
        # there is data in it, we should probably prompt the user about this
        if ( cached_table != null && !cached_table.is_empty() ):
            # Prompt user about saving old table
            request_save_file.emit()
            print( "Warning: Old table is not empty, data is lost..." )
            # And then we return here
            return
        # Otherwise the cached filepath should be updated
        cached_filepath = filePath
    # Open the file
    var file : FileAccess = FileAccess.open( filePath, FileAccess.READ )
    var table_data : TableData = TableData.new()
    if ( file ):
        filepath_used.emit( cached_filepath, FILE_PATH_ACTION.OPENED )
        # Discard the old table data by setting cached_table to null
        clear_cached_table( )
        # NOTE(klek): Do we need to check if the file is empty
        if ( file.get_length() == 0 ):
            # Then we just created this file, and we will just
            # return an empty table for now
            update_cached_table( table_data )
            return cached_table
        # Read data as text and parse this data directly with JSON
        var content = JSON.parse_string( file.get_as_text() )
        # Check that the content is a dictionary
        if ( content && ( content is Dictionary ) ):
            table_data = table_data.convert_from_dict( content )
        # Now we should have a valid table in table data
        if ( table_data != null && !table_data.is_empty() ):
            update_cached_table( table_data )
        else:
            print( "No data of expected format in file" )
    else:
        print( "Could not open filepath: %s" % filePath )
    # Finally return cached table
    return cached_table

# Function to simply update the cached table
func update_cached_table( table_data : TableData ) -> void:
    cached_table = table_data

# Function to simply clear the cached table
func clear_cached_table( ) -> void:
    cached_table = null
