@tool
class_name TextBox
extends PanelContainer

@export_multiline var text : String = "" : set = _set_text_label
@export var wrap_mode : TextServer.AutowrapMode = TextServer.AUTOWRAP_OFF : set = _set_wrap_mode

@onready var text_label: Label = %Text


func _set_text_label( value : String ) -> void:
    text = value
    if ( text_label ):
        text_label.text = text


func _set_wrap_mode( value : TextServer.AutowrapMode ) -> void:
    wrap_mode = value
    if ( text_label ):
        text_label.autowrap_mode = wrap_mode


func _process( _delta: float ) -> void:
    if ( text_label ):
        if ( text.is_empty() ):
            _set_text_label( text )
