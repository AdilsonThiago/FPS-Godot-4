extends Node3D

var velocidade = 100

func atirar(angulo):
	rotation = angulo
	pass

func _process(delta):
	$Area3D.position.z -= velocidade * delta
	pass

func _on_timer_timeout():
	queue_free()
	pass
