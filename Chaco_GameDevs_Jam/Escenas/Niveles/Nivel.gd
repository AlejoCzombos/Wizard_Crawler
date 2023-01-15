class_name Nivel
extends Node2D

## Atributos Export
export var musica_nivel:AudioStream = null
export(String, FILE, "*.tscn") var proximo_nivel = ""
export(String, FILE, "*.tscn") var menu_game_over = ""

onready var contenedor_enemigos:Node
onready var hud:HUD = $HUD

func _ready() -> void:
	Eventos.emit_signal("comenzar_oleada", DatosJuego.oleada_actual)
	conectar_seniales()
	contenedor_enemigos = Node.new()
	contenedor_enemigos.name = "contenedor_enemigos"
	add_child(contenedor_enemigos)
	MusicaJuego.set_streams(musica_nivel)
	MusicaJuego.play_musica_nivel()

func conectar_seniales() -> void:
# warning-ignore:return_value_discarded
	Eventos.connect("disparo", self, "_on_disparo")
# warning-ignore:return_value_discarded
	Eventos.connect("instanciar_enemigo", self, "on_instanciar_enemigo")
# warning-ignore:return_value_discarded
	Eventos.connect("disparo_enemigo", self, "_on_disparo_enemigo")
# warning-ignore:return_value_discarded
	Eventos.connect("descontar_enemigo", self, "on_descontar_enemigo")
# warning-ignore:return_value_discarded
	Eventos.connect("game_over", self, "game_over")

func game_over() -> void:
	MusicaJuego.stop_todo()
# warning-ignore:standalone_expression
	DatosJuego.nivel_actual = get_tree().current_scene.filename
# warning-ignore:return_value_discarded
	get_tree().change_scene(menu_game_over)

func on_descontar_enemigo() -> void:
	DatosJuego.cantidad_enemigos -= 1
	hud.descontar_enemigos()
	if DatosJuego.cantidad_enemigos == 0:
		Eventos.emit_signal("oleada_terminada")

func _on_disparo(proyectil:ProyectilPlayer) -> void:
	add_child(proyectil)

func _on_disparo_enemigo(proyectil:ProyectilEnemigo) -> void:
	call_deferred("add_child", proyectil)

func on_instanciar_enemigo(enemigo:EnemigoBase) -> void:
	add_child(enemigo)
