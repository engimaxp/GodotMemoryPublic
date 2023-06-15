extends Node
signal timeout
#var slow_factor = 1.0
#var old_slow_factor = slow_factor
@export var wait_time = 1.0:
	set = set_timer_wait_time
@export var is_loop = false
@export var is_autostart = false
var current_elasped_time = 0.0
var is_start = false :
	set = set_is_start
var time_left :
	get = get_time_left

func get_time_left():
	return wait_time - current_elasped_time

func is_stopped():
	return not is_start

func _ready():
	if is_autostart:
		set_is_start(true)

func stop():
	current_elasped_time = wait_time
	set_is_start(false)

func start():
	reset_timer()
	set_is_start(true)

func set_is_start(val):
	var f_val = is_start
	if f_val != val:
		is_start = val
		set_process(is_start)
		if not is_start:
			reset_timer()

func reset_timer():
	current_elasped_time = 0
	self.is_start = false
	
func set_timer_wait_time(val):
	wait_time = val
	
func _process(delta):
	if self.is_start:
		current_elasped_time += delta
		if current_elasped_time > wait_time:
			reset_timer()
			emit_signal("timeout")
			if is_loop:
				self.is_start = true
				

