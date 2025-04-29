class_name TableData
extends Resource

const c_max_int = ( pow(2, 62) )

enum TABLE_ACTIONS {
    COLUMN_CLICKED,
    COLUMN_GRAB_CLICKED,
    COLUMN_ADD_CLICKED,
    CARD_ADD_CLICKED,
    TABLE_CLICKED,

    TABLE_ACTION_UNDEF
}


## Signal generated when there is an interaction with this table_data
## This signal is primarily used for GUI interactions
signal table_data_interact( table_data : TableData, column_index : int, button : int, action : TABLE_ACTIONS )

## Signal generated when this table has been updated/changed in anyway
signal table_data_updated( table_data : TableData )

## The name of this table
@export var title : String = ""

# TODO(klek): Add a background color for the table
@export var bg_color : Color

## The columns associated with this table
@export var column_datas : Array[ ColumnData ]

#
func convert_to_dict( ) -> Dictionary:
    var dict : Dictionary
    # Store the title of the table
    dict["title"] = title
    # Store the bg_color
    dict["bg_color"] = [ bg_color.r, bg_color.b, bg_color.g, bg_color.a ]
    # Create an array of dictionaries for each column
    var column_array : Array[ Dictionary ]
    for column_data in column_datas:
        # Check for valid entry
        if ( column_data ):
            column_array.push_back( column_data.convert_to_dict() )
    # Store the column_datas in the main dict
    dict["column_datas"] = column_array

    return dict

#
func convert_from_dict( table_dict : Dictionary ) -> TableData:
    # TODO(klek): Might need to do sanity-checking here?
    var table_data : TableData = TableData.new()
    # Read in the title
    if ( table_dict.get("title") && \
         typeof( table_dict.get("title") ) == TYPE_STRING ):
        table_data.title = table_dict.get("title") as String
    # Read in the bg_color
    if ( table_dict.get("bg_color") && \
         typeof( table_dict.get("bg_color") ) == TYPE_ARRAY ):
        # Read in data as r, g, b, a
        table_data.bg_color = Color( table_dict["bg_color"][0], \
                                     table_dict["bg_color"][1], \
                                     table_dict["bg_color"][2], \
                                     table_dict["bg_color"][3], )
    # Now we need to read in the potential column_datas
    if ( table_dict.get("column_datas") && \
         typeof( table_dict.get("column_datas") ) == TYPE_ARRAY ):
        var column_array : Array = table_dict.get("column_datas")
        # Now we need to extract the individual columns and add them to column_datas
        for column in column_array:
            if ( typeof( column ) == TYPE_DICTIONARY ):
                var column_data : ColumnData = ColumnData.new()
                table_data.column_datas.push_back( column_data.convert_from_dict( column ) )
    return table_data

#
func is_empty() -> bool:
    # If the title isn't set and column_datas is empty, the table
    # is currently considered empty
    return ( title.is_empty() && column_datas.is_empty() )

#
func grab_column_data( index : int ) -> ColumnData:
    return remove_column_data( index )

#
func add_column_data( column_data : ColumnData ) -> void:
    if ( column_datas.size() < 1 ):
        print( "Empty array" )
    else:
        print( "%d elements in array" % column_datas.size() )
    # Adding a column_data is easy
    if ( column_data.column_index >= column_datas.size() ):
        column_datas.push_back( column_data )
    elif ( column_data.column_index < 0 ):
        column_datas.push_front( column_data )
    else:
        column_datas.insert( column_data.column_index, column_data )
    table_data_updated.emit( self )


#
func remove_column_data( index : int ) -> ColumnData:
    # Get the current size of the array
    var size : int = column_datas.size()
    var column_data : ColumnData
    if ( size < index ):
        # We do nothing, trying to remove a index outside of the array
        push_error( "Array-size is %d but index is %d" % [ size, index ] )
        return null
    # NOTE(klek): We could always pop_at here right?
    column_data = column_datas.pop_at( index )
    table_data_updated.emit( self )
    return column_data


## This callback needs to be connected from the GUI side, when this column
## is clicked
func _on_column_clicked( column_index : int, button : int, action : ColumnData.COLUMN_ACTIONS ) -> void:
    match ( action ):
        ColumnData.COLUMN_ACTIONS.COLUMN_CLICKED:
            # Do we need to add a new dataslot to this column?
            table_data_interact.emit( self, column_index, button, TABLE_ACTIONS.COLUMN_CLICKED )
        ColumnData.COLUMN_ACTIONS.COLUMN_GRAB_CLICKED:
            table_data_interact.emit( self, column_index, button, TABLE_ACTIONS.COLUMN_GRAB_CLICKED )
        ColumnData.COLUMN_ACTIONS.CARD_ADD_CLICKED:
            table_data_interact.emit( self, column_index, button, TABLE_ACTIONS.CARD_ADD_CLICKED )
        ColumnData.COLUMN_ACTIONS.COLUMN_REMOVE_CLICKED:
            remove_column_data( column_index )
            # Call local remove column function and the emit table update
            table_data_updated.emit( self )

func _on_column_add_clicked(  ) -> void:
    # We emit
    table_data_interact.emit( self, 0, 0, TABLE_ACTIONS.COLUMN_ADD_CLICKED )
