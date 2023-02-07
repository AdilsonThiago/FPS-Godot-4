extends CharacterBody3D

const SPEED = 5.0 #define velocidade máxima
const JUMP_VELOCITY = 4.5 #define velocidade de pulo

# Pega a gravidade direto das configurações do projeto
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sensibilidade = 0.5 #sensibilidade do mouse
var animacao_atual = "parado"
var nova_animacao = animacao_atual
var intervalo_tiro = 0
var packed_bala = preload("res://bala.tscn")

func _ready():
	#iniciar gravação do mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	#identifica se a entrada é a movimentação do mouse
	if event is InputEventMouseMotion:
		#rotacion o CharacterBody3D no eixo y
		rotate_y(- deg_to_rad(event.relative.x * sensibilidade))
		#rotaciona a camera no eixo x
		$Camera3D.rotate_x(- deg_to_rad(event.relative.y * sensibilidade))
		#ajusta a rotação da camera para previnir visão invertida
		var rotacao_ajustada = clamp($Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		#camera recebe a nova visao ajustada
		$Camera3D.rotation.x = rotacao_ajustada
	elif event.is_action_pressed("b_sair"):
		#a endtrada do jogador foi o botão de sair
		get_tree().quit()#simplesmente encerra o jogo
	if event.is_action_pressed("mouse_besquerdo"):
		shoot()
	pass

func shoot():
	if intervalo_tiro <= 0:
		var o = packed_bala.instantiate()
		get_parent().add_child(o)
		o.position = position
		o.atirar(Vector3($Camera3D.rotation.x, rotation.y, 0))
		nova_animacao = "atirando"
		intervalo_tiro = 0.4
	pass

func animacao():
	if not nova_animacao == animacao_atual:
		$AnimationPlayer.play(nova_animacao)
		animacao_atual = nova_animacao
	pass

func _process(delta):
	if intervalo_tiro > 0:
		intervalo_tiro -= delta
	animacao()
	pass

func _physics_process(delta):
	#Pega o vetor de movimentação do teclado (W, A, S, D)
	var axys = Input.get_vector("b_esquerda", "b_direita", "b_cima", "b_baixo")
	#Pega o vetor de movimentação para frente multiplicado pelo valor da tecla (se não estiver pressionando nem W nem S o valor será zero e o vetor também sera zerado
	var vetor_frente = transform.basis.z * axys.y
	#Mesma função do anterior, mas agora para a movimentação horizontal
	var vetor_lado = transform.basis.x * axys.x
	#Somando os vetores, normalizando, e aplicando a velocidade
	var vetor_final = (vetor_frente + vetor_lado).normalized() * SPEED
	if intervalo_tiro <= 0:
		if not axys.x == 0 or not axys.y == 0:
			nova_animacao = "andando"
		else:
			nova_animacao = "parado"
	if is_on_floor():
		#Se estiver no chão a gravidade é zerada
		velocity.y = 0
		if Input.is_action_just_pressed("b_pular"):
			#Caso tenha pressionado o botão de pular é aplicado então uma velocidade de pulo
			velocity.y = JUMP_VELOCITY
	else:
		#O jogador não está no chão então é necessário aplicar gravidade
		velocity.y -= gravity * delta
	#Aplicando o vetor de movimento com o vetor de gravidade
	velocity = vetor_final + Vector3(0, velocity.y, 0)
	#Efetivamente movimentando...
	move_and_slide()
	pass
