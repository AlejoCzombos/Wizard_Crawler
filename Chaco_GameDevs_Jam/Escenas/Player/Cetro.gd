class_name Cetro
extends Node2D

export var proyectil:PackedScene = null
export var cadencia_disparo: float = 0.1
export var velocidad_proyectil: int = 1000
export var danio_proyectil: float = 1

onready var punto_disparo:Position2D = $PosicionDisparo
onready var timer_enfriamiento: Timer = $TimerEnfriamiento
onready var esta_enfriado:bool = true
onready var esta_disparando:bool = false setget set_esta_disparando
onready var puede_disparar:bool = false setget set_puede_disparar

func set_esta_disparando(disparando: bool) -> void:
	esta_disparando = disparando

func set_puede_disparar(disparando: bool) -> void:
	puede_disparar = disparando

func _ready() -> void:
	timer_enfriamiento.wait_time = cadencia_disparo

func _process(_delta: float) -> void:
	if esta_disparando && esta_enfriado && puede_disparar:
		disparar()

func disparar() -> void:
	esta_enfriado = false
	timer_enfriamiento.start()
	var new_proyectil:Proyectil = proyectil.instance()
	new_proyectil.crear(
		punto_disparo.global_position,
		global_rotation,
		velocidad_proyectil,
		danio_proyectil
		)
	Eventos.emit_signal("disparo", new_proyectil)


func _on_TimerEnfriamiento_timeout():
	esta_enfriado = true