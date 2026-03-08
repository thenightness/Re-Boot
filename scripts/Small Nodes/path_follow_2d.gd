extends PathFollow2D

@export var duration: float = 2.0  # Zeit für eine Strecke

func _ready():
	start_patrol()

func start_patrol():
	# wiederholt sich endlos
	var tween = create_tween().set_loops()
	
	# Phase 1: Von Start (0) zum Ende (1)
	tween.tween_property(self, "progress_ratio", 1.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# Phase 2: Vom Ende (1) zurück zum Start (0)
	tween.tween_property(self, "progress_ratio", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
