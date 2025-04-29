class_name ColumnData
extends Resource

const c_max_int : int = int( pow(2, 62) )

# Actions on a column_data
enum COLUMN_ACTIONS {
    CARD_CLICKED,
    CARD_ADD_CLICKED,
    CARD_REMOVE_CLICKED,
    COLUMN_CLICKED,
    COLUMN_ADD_CLICKED,
    COLUMN_REMOVE_CLICKED,
    COLUMN_GRAB_CLICKED,

    COLUMN_ACTION_UNDEF
}

## Signal generated when there is an interaction with this column_data
## This signal is primarily used for GUI interactions
signal column_data_interact( column_data : ColumnData, card_index : int, button : int, action : COLUMN_ACTIONS )

## Signal generated when a card should be added to the column data
## This signal is primarily used for GUI interactions
# TODO(klek): Consider merging this with column_interact above and use
# an action table instead
#signal column_add_card( column_data : ColumnData, index : int )

## Signal generated when this column has been updated/changed in anyway
signal column_data_updated( column_data : ColumnData )

## The width of this column in characters
@export var column_width : int = 70 : set = _set_column_width

## The title of this column, ie "Backlog", "Completed", "In-progress" etc
@export var column_title : String = "" : set = _set_title

## The position this column should have starting from left
## If two columns have the same position, they should be put
## in order they are read
@export var column_index : int = 0 : set = _set_column_index

# TODO(klek): Add background option etc

## The currently available cards
@export var card_datas : Array[ CardData ]


func _set_column_width( value : int ) -> void:
    column_width = value
    column_data_updated.emit( self )


func _set_title( value : String ) -> void:
    # TODO(klek): Enforce the column width
    column_title = value
    column_data_updated.emit( self )


func _set_column_index( value : int ) -> void:
    column_index = value
    column_data_updated.emit( self )


func convert_to_dict() -> Dictionary:
    var dict : Dictionary
    # Store the title, column-width and index
    dict["column_title"] = column_title
    dict["column_width"] = column_width
    dict["column_index"] = column_index
    # Create an array of dictionaries for each card
    var card_array : Array[ Dictionary ]
    for card_data in card_datas:
        # Check for valid entry
        if ( card_data ):
            card_array.push_back( card_data.convert_to_dict() )
    dict["card_datas"] = card_array
    return dict


func convert_from_dict( column_dict : Dictionary ) -> ColumnData:
    # TODO(klek): Might need to sanity-check all data here
    var column_data : ColumnData = ColumnData.new()
    # Read in the title
    if ( column_dict.get("column_title") && \
         typeof( column_dict.get("column_title") ) == TYPE_STRING ):
        column_data.column_title = column_dict.get("column_title") as String
    # Read in the bg_color
    if ( column_dict.get("column_width") && \
         typeof( column_dict.get("column_width") ) == TYPE_INT ):
        column_data.column_width = column_dict.get("column_width")
        #if ( column_data.column_width == 0 ):
            #column_data.column_width = 70
    # Read in column_index
    if ( column_dict.get("column_index") && \
         typeof( column_dict.get("column_index") ) == TYPE_INT ):
        column_data.column_index = column_dict.get("column_index")
    # Now we need to read in the potential column_datas
    if ( column_dict.get("card_datas") && \
         typeof( column_dict.get("card_datas") ) == TYPE_ARRAY ):
        var card_array : Array = column_dict.get("card_datas")
        # Now we need to extract the individual columns and add them to column_datas
        for card in card_array:
            if ( typeof( card ) == TYPE_DICTIONARY ):
                var card_data : CardData = CardData.new()
                column_data.card_datas.push_back( card_data.convert_from_dict( card ) )
    return column_data


#
func grab_card_data( index : int ) -> CardData:
    return remove_card_data( index )


func drop_card_data( grabbed_card_data : CardData, index : int ) -> CardData:
    print( "Index is ", index )
    # Store the data at the current index
    var card_data : CardData = card_datas[ index ]
    var return_card_data : CardData
    # Is there currently anything in this card?
    if ( card_data ):
        # Then we effectively swapped the two cards
        card_datas[ index ] = grabbed_card_data
        return_card_data = card_data
    else:
        card_datas[ index ] = grabbed_card_data
    # Emit the change
    column_data_updated.emit( self )
    # Otherwise we return null
    return return_card_data


func add_card_data( grabbed_card_data : CardData, index : int = c_max_int ) -> void:
    if ( card_datas.size() < 1 ):
        print( "Empty array" )
    else:
        print( "%d elements in array" % card_datas.size() )
    # Adding a card is easy
    if ( index == c_max_int ):
        card_datas.push_back( grabbed_card_data )
    else:
        card_datas.insert( index, grabbed_card_data )
    column_data_updated.emit( self )


func remove_card_data( index : int ) -> CardData:
    # Get the current size of the array
    var size : int = card_datas.size()
    var card_data : CardData
    if ( size < index ):
        # We do nothing, trying to remove a index outside of the array
        push_error( "Array-size is %d but index is %d" % [ size, index ] )
        return null
    # NOTE(klek): We could always pop_at here right?
    card_data = card_datas.pop_at( index )
    column_data_updated.emit( self )
    return card_data


## This callback needs to be connected from the GUI side, when this column
## is clicked
func _on_card_clicked( card_index : int, action : CardData.CARD_ACTIONS, button : int ) -> void:
    match ( action ):
        CardData.CARD_ACTIONS.CARD_CLICKED:
            column_data_interact.emit( self, card_index, button, COLUMN_ACTIONS.CARD_CLICKED )
            print( "Card clicked again" )
        CardData.CARD_ACTIONS.CARD_EDIT_CLICKED:
            pass
        CardData.CARD_ACTIONS.CARD_REMOVE_CLICKED:
            # Here we want to remove the card at the index, and emit the
            # column_updated
            remove_card_data( card_index )
            #column_interact.emit( self, card_index, button, COLUMN_ACTIONS.CARD_REMOVE )
            column_data_updated.emit( self )
            print( "Card remove clicked" )

## This callback needs to be connected from the GUI side, when the add_card
## button is clicked
func _on_add_card_clicked( _column_index : int ) -> void:
    column_data_interact.emit( self, _column_index, COLUMN_ACTIONS.CARD_ADD_CLICKED )
    print( "Add card clicked" )

#func _on_remove_card_clicked( column_index : int ) -> void:
    ## NOTE(klek): Do I need to get the index?
    #column_interact.emit( self, column_index, COLUMN_ACTIONS.CARD_REMOVE )
    #print( "Remove card clicked" )
