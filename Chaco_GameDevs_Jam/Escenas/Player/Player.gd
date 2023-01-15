class_name Player
extends KinematicBody2D

enum ESTADO {SPAWN, VIVO, INVENCIBLE, MUERTO}

export var velocidad:float = 400.0
export var vida:float = 10.0
export var cadencia_disparo:float = 1
export var velocidad_proyectil:int = 1000
export var danio_proyectil:float = 2

onready var sprite:AnimatedSprite = $AnimatedSprite
onready var animaciones:AnimationPlayer = $AnimationPlayer
onready var cetro = $RotacionCetro/Cetro
onready var colisionador:CollisionShape2D = $CollisionShape2D
onready var rotacionCetro:CollisionShape2D = $RotacionCetro

var vidaMax:float
var nivel_evolucion:int = 1
var estadoActual:int = ESTADO.VIVO

func _ready() -> void:
	DatosJuego.player_actual = self
	controladorEstado(estadoActual)
	configurar_cetro()
	Eventos.connect("mejoraSeleccionada", self, "on_mejoraSeleccionada")
	$RotacionCetro/Cetro/TimerEnfriamiento.wait_time = cadencia_disparo
	$RotacionCetro/Cetro.velocidad_proyectil = velocidad_proyectil
	vidaMax = vida

func _exit_tree() -> void:
	DatosJuego.player_actual = null

func on_mejoraSeleccionada(mejora:int) -> void:
	nivel_evolucion += 1
	if nivel_evolucion == 3 && nivel_evolucion == 6 && nivel_evolucion == 9 && nivel_evolucion == 12 && nivel_evolucion == 15:
		evolucionar()
	# 0 = Daño
	# 1 = Tario de fuego
	# 2 = Vida
	# 3 = Velocidad
	match mejora:
		0: 
			danio_proyectil = danio_proyectil * 1.5
			cetro.danio_proyectil = danio_proyectil
			pass
		1:
			cadencia_disparo = cadencia_disparo 
			$RotacionCetro/Cetro/TimerEnfriamiento.wait_time = (cadencia_disparo - 0.2)
			pass
		2:
			vidaMax = vidaMax * 1.4
			vida = vidaMax
			Eventos.emit_signal("subidaVida", vida)
			pass
		3:
			velocidad = velocidad + 70
			pass
		_:
			printerr("Error mejora")

func evolucionar() -> void:
	if nivel_evolucion < 6:
		var nivel = "Nivel" + str(nivel_evolucion-1)
		print(nivel)
		sprite.play(nivel)
		$RotacionCetro/Cetro/Sprite.play(nivel)
		if nivel_evolucion == 3 || nivel_evolucion == 5:
			Eventos.emit_signal("cambio_nivel_proyectil")

func configurar_cetro() -> void:
	cetro.cadencia_disparo = 0.7
	cetro.velocidad_proyectil = 800
	cetro.danio_proyectil = 2

func _process(_delta) -> void:
	#MOVIMIENTO----------------------
	var movimiento:Vector2 = Vector2.ZERO
	if Input.is_action_pressed("Derecha"):
		movimiento.x += 1
	if Input.is_action_pressed("Izquierda"):
		movimiento.x -= 1
	if Input.is_action_pressed("Abajo"):
		movimiento.y += 1
	if Input.is_action_pressed("Arriba"):
		movimiento.y -= 1
	
	#DISPARO-----------------------------
	if Input.is_action_pressed("Disparar"):
		cetro.set_esta_disparando(true)
	elif Input.is_action_just_released("Disparar"):
		cetro.set_esta_disparando(false)
	
	if movimiento.length() > 0:
		movimiento = movimiento.normalized() * velocidad
		animaciones.play("Correr")
	else:
		if !animaciones.is_playing():
			animaciones.play("Idle")
	
	if movimiento.x < 0:
		sprite.flip_h = true
	elif movimiento.x > 0 :
		sprite.flip_h = false
	
	#Rotacion del Cetro
	rotacionCetro.look_at(get_global_mouse_position())
	
	if rotacionCetro.rotation_degrees > 360:
		rotacionCetro.rotation_degrees = 0
	elif rotacionCetro.rotation_degrees < 0:
		rotacionCetro.rotation_degrees = 360
	
	if rotacionCetro.rotation_degrees > 90 && rotacionCetro.rotation_degrees < 270:
		$RotacionCetro/Cetro/Sprite.flip_v = true
		cetro.rotacio_negativa = true
	else: 
		$RotacionCetro/Cetro/Sprite.flip_v = false
		cetro.rotacio_negativa = false
	
	#Movimiento Player
	#position += movimiento * delta
	move_and_slide(movimiento)

func controladorEstado(nuevoEstado: int) -> void:
	match nuevoEstado:
		ESTADO.SPAWN:
			colisionador.set_deferred("disabled", true)
			cetro.set_puede_disparar(false)
		ESTADO.VIVO:
			colisionador.set_deferred("disabled", false)
			cetro.set_puede_disparar(true)
		ESTADO.INVENCIBLE:
			colisionador.set_deferred("disabled", true)
		ESTADO.MUERTO:
			colisionador.set_deferred("disabled", true)
			cetro.set_puede_disparar(false)
			queue_free()
		_:
			printerr("Error estados")
	estadoActual = nuevoEstado

func recibir_danio(danio:float) -> void:
	DatosJuego.camara_actual.movimientoCamara(4,0.3)
	Eventos.emit_signal("danio_jugador")
	if danio > vida:
		Eventos.emit_signal("game_over")
	if vida > 0:
		vida -= danio
		animaciones.play("Danio")
		Eventos.emit_signal("camera_shake_requested")
		Eventos.emit_signal("cambio_vida", vida)
		#Borrar test
		print(vida)
