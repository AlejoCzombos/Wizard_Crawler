class_name ProyectilEnemigo
extends Proyectil

func crear(pos: Vector2, dir: float, vel: float, nuevo_danio:float, nivel:int) -> void:
	position = pos
	rotation = dir
	velocidad = Vector2(vel, 0).rotated(dir)
	danio = nuevo_danio