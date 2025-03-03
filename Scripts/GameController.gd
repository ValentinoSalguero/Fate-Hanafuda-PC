extends Node

var mazo : Array = []
var jugadores : Array = []
var num_jugadores : int = 2
var jugador_actual : int = 0

const Player = preload("res://Scripts/Player.gd")

func _ready():
	crear_mazo()
	repartir_cartas()
	mostrar_cartas_en_pantalla()
	mostrar_mazo()

func crear_mazo():
	var meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
	for mes in meses:
		for i in range(1, 5):
			var carta = load("res://Scenes/Card.tscn").instantiate()
			carta.inicializar(mes, i)
			mazo.append(carta)

	mazo.shuffle()

func mostrar_mazo():
		var screen_size = get_viewport().get_visible_rect().size
		var mazo_x = screen_size.x * 0.1
		var mazo_y = screen_size.y / 2
		var num_cartas_mostradas = 5
		var offset = 4

		for i in range(num_cartas_mostradas):
				var mazo_sprite = Sprite2D.new()
				mazo_sprite.texture = load("res://Images/Dorso.png")
				mazo_sprite.position = Vector2(mazo_x - i * offset, mazo_y - i * offset)
				add_child(mazo_sprite)
				mazo_sprite.z_index = i

func repartir_cartas():
	for i in range(num_jugadores):
		var jugador = Player.new()
		jugadores.append(jugador)

	var i = 0
	for carta in mazo:
		jugadores[i % num_jugadores].agregar_carta(carta)
		i += 1

func siguiente_turno():
	jugador_actual = (jugador_actual + 1) % num_jugadores
	print("Es el turno del jugador " + str(jugador_actual + 1))

func mostrar_cartas_en_pantalla():
	var screen_size = get_viewport().size
	var center_x = screen_size.x / 2
	var center_y = screen_size.y / 2
	
	var filas = 2
	var columnas = 4
	
	var num_cartas = 8
	var espacio_x = 118
	var espacio_y = 190
	var cartas_colocadas = 0
	
	var meses_colocados = {}
	
	for i in range(mazo.size()):
		if cartas_colocadas >= num_cartas:
			break
		
		var carta = mazo[i]
		var mes = carta.mes
		
		if meses_colocados.has(mes) and meses_colocados[mes] >= 2:
			continue
		
		add_child(carta)
		var fila = cartas_colocadas / columnas
		var columna = cartas_colocadas % columnas
		
		var pos_x = center_x + (columna - (columnas / 2)) * espacio_x
		var pos_y = center_y + (fila - (filas / 2)) * espacio_y
		
		carta.position = Vector2(pos_x, pos_y)
		
		cartas_colocadas += 1
		if not meses_colocados.has(mes):
			meses_colocados[mes] = 0
		meses_colocados[mes] += 1
	
	if cartas_colocadas < num_cartas:
		for i in range(mazo.size()):
			if cartas_colocadas >= num_cartas:
				break
			var carta = mazo[i]
			var mes = carta.mes
			
			if meses_colocados.has(mes) and meses_colocados[mes] >= 2:
				continue
			
			add_child(carta)
			var fila = cartas_colocadas / columnas
			var columna = cartas_colocadas % columnas
			
			var pos_x = center_x + (columna - (columnas / 2)) * espacio_x
			var pos_y = center_y + (fila - (filas / 2)) * espacio_y
			
			carta.position = Vector2(pos_x, pos_y)
			
			cartas_colocadas += 1
			if not meses_colocados.has(mes):
				meses_colocados[mes] = 0
			meses_colocados[mes] += 1

func verificar_ganador():
	for i in range(num_jugadores):
		if jugadores[i].calcular_puntos() >= 100:
			print("¡Jugador " + str(i + 1) + " ha ganado!")
			return true
	return false
