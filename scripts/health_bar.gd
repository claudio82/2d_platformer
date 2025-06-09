extends TextureProgressBar

@onready var progress_under = $ProgressUnder

var duration = 0.5

func change_value(new_value):
	value = new_value
	
	var tween = get_tree().create_tween()
	tween.tween_property(progress_under, "value", new_value, duration)
