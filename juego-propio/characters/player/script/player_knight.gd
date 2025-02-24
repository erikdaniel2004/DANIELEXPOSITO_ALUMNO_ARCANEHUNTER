extends CharacterBody2D

@export var gravity_scale = 2
@export var speed = 200
@export var acceleration = 200
@export var friction = 900
@export var jump_force = -550
@export var air_acceleration = 1500
@export var air_friction = 700

@onready var ani_player = $ani_player
@onready var time = $time
@onready var audio_player = $audio_player

# Referencia al contador de monedas
@onready var contador: Control = $CanvasLayer/contador_moneda

# Referencia al contador de runas
@onready var contador2: Control = $CanvasLayer2/contador_runa

# Contadores
var monedas = 0
var runas = 0

# Altura límite para morir
@export var death_y_threshold: float = 1500

func _ready():
	add_to_group("player_knight")
	contador.actualizar(0)
	contador2.actualizar(0)

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_scale

func handle_acceleration(input_axis, delta):
	if not is_on_floor():
		return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, acceleration * delta)

func _physics_process(delta: float) -> void:
	var input_axis = Input.get_axis("mover_izquierda", "mover_derecha")

	# Si cae por debajo del límite, muere
	if global_position.y > death_y_threshold:
		morir()

	apply_gravity(delta)
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	handle_jump()
	handle_air_acceleration(input_axis, delta)
	update_animation(input_axis)
	move_and_slide()

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("saltar"):
			velocity.y = jump_force

func handle_air_acceleration(input_axis, delta):
	if is_on_floor():
		return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, speed * input_axis, air_acceleration * delta)

func update_animation(input_axis):
	if input_axis != 0:
		ani_player.speed_scale = velocity.length() / 100
		ani_player.flip_h = (input_axis < 0)
		ani_player.play("run")
	elif not is_on_floor():
		ani_player.play("jump")
	else:
		ani_player.speed_scale = 1
		ani_player.play("idle")

# Función para sumar monedas
func sumar_monedas(valor):
	monedas += valor
	contador.actualizar(monedas)
	
# Función para sumar runas
func obtener_runa(valor):
	runas += valor
	contador2.actualizar(runas)

# Función para la muerte del jugador
func morir():
	audio_player.play() 
	ani_player.play("dead")
	set_physics_process(false)
	time.start()
	await time.timeout
	get_tree().reload_current_scene()
