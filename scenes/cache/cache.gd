class_name Cache
extends Node

@export var current_table : TableData

var current_filepath : String


# Internal variables
#var _valid_filename_regex : RegEx = RegEx.new()
#var _json : JSON = JSON.new()


#func _enter_tree() -> void:
#    _valid_filename_regex.compile("[0-9]{4}-[0-9]{2}-[0-9]{2}.txt")


func save_file( table_data : TableData ) -> void:
    var file : = FileAccess.open( "res://save_data.json", FileAccess.WRITE )
    if ( file ):
        # NOTE(klek): Do we need to check if the file is empty?
        var data_to_save : Dictionary = table_data.convert_to_dict()
        file.store_string( JSON.stringify( data_to_save, "\t" ) )
        file.close()
    ResourceSaver.save( table_data, "res://save_data.tres")


func load_file( filename : String ) -> TableData:
    # NOTE(klek): This is temporary
    # Open the file
    var file : FileAccess = FileAccess.open( filename, FileAccess.READ )
    var table_data : TableData = TableData.new()
    if ( file ):
        # NOTE(klek): Do we need to check if the file is empty
        if ( file.get_length() == 0 ):
            # Then we just created this file, and we will just
            # return an empty table for now
            return table_data
        # Read data as text and parse this data directly with JSON
        var content = JSON.parse_string( file.get_as_text() )
        # Check that the content is a dictionary
        if ( content && ( content is Dictionary ) ):
            table_data = table_data.convert_from_dict( content )
    # Finally return table_data
    return table_data

#func load_file( directory_path : String, filename : String ) -> void:
    #if ( _valid_filename_regex.search( filename ) ):
        #push_error("%s is not a valid file" % filename )
        #return
    ## Set a full-path
    #var full_path : String = directory_path.path_join( filename )
    ## Try to open the file
    #var file : = FileAccess.open( full_path, FileAccess.READ )
    #if ( file ):
        ## If the file is empty we ignore it for now
        #if ( file.get_length() == 0 ):
            #return
        #JSON.new()
