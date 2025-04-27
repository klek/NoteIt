class_name TableData
extends Resource

## Signal generated when there is an interaction with this table_data
## This signal is primarily used for GUI interactions
signal table_interact( table_data : TableData, index : int, button : int )

## Signal generated when this table has been updated/changed in anyway
signal table_updated( table_data : TableData )

## The name of this table
@export var title : String = ""

# TODO(klek): Add a background color for the table
@export var bg_color : Color

## The columns associated with this table
@export var column_datas : Array[ ColumnData ]


func grab_column_data( index : int ) -> ColumnData:
    var column_data : ColumnData = column_datas[ index ]
    # Is there something there?
    if ( column_data ):
        # Set the current index to null
        column_datas[ index ] = null
        table_updated.emit( self )
        return column_data
    else:
        return null


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


## This callback needs to be connected from the GUI side, when this column
## is clicked
func _on_column_clicked( index : int, button : int ) -> void:
    # Do we need to add a new dataslot to this column?
    table_interact.emit( self, index, button )
    print( "Column clicked again" )
