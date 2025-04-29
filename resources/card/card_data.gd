class_name CardData
extends Resource

enum CARD_ACTIONS {
    CARD_CLICKED,
    CARD_EDIT_CLICKED,
    CARD_REMOVE_CLICKED,

    CARD_ACTION_UNDEF
}

@export var title : String = "" : set = _set_title_text

@export_multiline var description : String = "" : set = _set_description_text

@export var wrap_text : bool = true

# TODO(klek): Consider enforcing a maximum number of characters for title and
# description. For example 70 character limit on title and 3 times that for
# description


func _set_title_text( value : String ) -> void:
    title = value


func _set_description_text( value : String ) -> void:
    description = value
    # TODO(klek): Determine if the we should force wrap to on here


func convert_to_dict() -> Dictionary:
    var dict : Dictionary
    # Store the title, column-width and index
    dict["title"] = title
    dict["description"] = description
    dict["wrap_text"] = wrap_text
    return dict


func convert_from_dict( card_dict : Dictionary ) -> CardData:
    # TODO(klek): Might need to sanity-check all data here
    var card_data : CardData = CardData.new()
    if ( card_dict.get( "title" ) && \
         typeof( card_dict.get( "title" ) ) == TYPE_STRING ):
        card_data.title = card_dict.get( "title" )
    if ( card_dict.get( "description" ) && \
         typeof( card_dict.get( "description" ) ) == TYPE_STRING ):
        card_data.description = card_dict.get( "description" )
    if ( card_dict.get( "wrap_text" ) && \
         typeof( card_dict.get( "wrap_text" ) ) == TYPE_BOOL ):
        card_data.wrap_text = card_dict.get( "wrap_text" )
    # NOTE(klek): Do we need to duplicate here?
    return card_data
