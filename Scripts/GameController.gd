extends Node

const FondoScene = preload("res://Scenes/Background.tscn")

var mazo : Array = []
var jugadores : Array = []
var num_jugadores : int = 2
var jugador_actual : int = 0

const Player = preload("res://Scripts/Player.gd")
const CardScene = preload("res://Scenes/Card.tscn") # Preload la escena de la carta

func _ready():
	var fondo = FondoScene.instantiate()
	add_child(fondo)
	fondo.z_index = -1
	crear_mazo()
	iniciar_jugadores()
	mostrar_mazo()

func iniciar_jugadores():
	jugadores.clear()
	for i in range(num_jugadores):
		var jugador = Player.new()
		jugadores.append(jugador)

func crear_mazo():
	var meses = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
	for mes in meses:
		for i in range(1, 5):
			var carta = CardScene.instantiate()
			carta.inicializar(mes, i)
			mazo.append(carta)
	mazo.shuffle()

func mostrar_mazo():
	var screen_size = get_viewport().get_visible_rect().size
	var mazo_x = screen_size.x * 0.1
	var mazo_y = screen_size.y / 2
	var num_cartas_mostradas_inicial = 48
	var offset = 4
	var tiempo_entre_cartas = 0.1

	var cartas_animacion : Array = []

	for i in range(num_cartas_mostradas_inicial):
		var mazo_sprite = Sprite2D.new()
		mazo_sprite.texture = load("res://Images/Dorso.png")
		mazo_sprite.position = Vector2(mazo_x + 300, screen_size.y + 95)
		mazo_sprite.scale = Vector2(0.7, 0.7) # Ajusta la escala aquí
		add_child(mazo_sprite)
		mazo_sprite.z_index = i
		cartas_animacion.append(mazo_sprite)

		var posicion_final = Vector2(mazo_x - (i) * offset, mazo_y - (i) * offset)
		var tween = create_tween()
		tween.tween_property(mazo_sprite, "position", posicion_final, 0.22).set_delay(i * tiempo_entre_cartas)

		if i == num_cartas_mostradas_inicial - 1:
			tween.tween_callback(Callable(self, "_on_mazo_animacion_terminada").bind(cartas_animacion))
			
func _on_mazo_animacion_terminada(cartas_animacion : Array):
	for i in range(cartas_animacion.size()):
		if i >= 10: # Eliminar las cartas adicionales
			cartas_animacion[i].queue_free()
		else:
			cartas_animacion[i].add_to_group("cartas_mazo") # Agregar las 10 cartas finales al grupo
	repartir_cartas()

func repartir_cartas():
	var i = 0
	var mazo_x = get_viewport().get_visible_rect().size.x * 0.1
	var mazo_y = get_viewport().get_visible_rect().size.y / 2

	if jugadores.size() == 0:
		print("Error: No hay jugadores inicializados")
		return

	var cartas_repartidas = 0
	var orden_reparto = [0, 1, "mesa", 0, 1, "mesa"]
	var contador_orden = 0
	var contadores_jugadores = [0, 0] # Contadores para cada jugador

	for carta in mazo.slice(0, 24):
		if carta.has_node("Sprite2D"):
			var carta_sprite = carta.get_node("Sprite2D")
			carta_sprite.texture = load("res://Images/Dorso.png")
			carta.position = Vector2(mazo_x, mazo_y)
			add_child(carta)

			var destino = orden_reparto[contador_orden / 4]
			if typeof(destino) == TYPE_STRING and destino == "mesa":
				var pos = calcular_posicion_carta(i % 8)
				var tween = create_tween()
				tween.tween_property(carta, "position", pos, 0.5).set_delay(i * 0.1)
				tween.tween_callback(Callable(self, "voltear_carta").bind(carta_sprite, carta, i))
			else:
				var jugador_actual = jugadores[destino]
				jugador_actual.mano.append(carta)

				var pos = calcular_posicion_carta_jugador(contadores_jugadores[destino], jugador_actual) # Usar contador del jugador
				var tween = create_tween()
				tween.tween_property(carta, "position", pos, 0.5).set_delay(i * 0.1)
				if jugador_actual != jugadores[1]:
					tween.tween_callback(Callable(self, "voltear_carta").bind(carta_sprite, carta, i))

				contadores_jugadores[destino] += 1 # Incrementar el contador del jugador

			i += 1
			cartas_repartidas += 1
			contador_orden += 1

			if cartas_repartidas % 4 == 0:
				disminuir_mazo()
		else:
			print("Error: La carta no tiene un Sprite2D")
			
func voltear_carta(carta_sprite: Sprite2D, carta: Node2D, index: int):
	# Acceder al Sprite2D dentro de la instancia de carta
	if index >= 8 and index < 16: # Solo voltear las cartas del jugador 1 y mesa
		carta.mostrar_frente()
		return

	var tween = create_tween()
	tween.tween_property(carta_sprite, "scale:x", 0, 0.2)
	tween.tween_callback(Callable(self, "_mostrar_frente_carta").bind(carta_sprite, carta)) # Usar sprite_carta en lugar de carta_sprite

func _mostrar_frente_carta(carta_sprite: Sprite2D, carta: Node2D):
	carta.mostrar_frente() # Llamar a la función mostrar_frente() de card.gd
	var tween = create_tween()
	tween.tween_property(carta_sprite, "scale:x", 1, 0.2)
	
func calcular_posicion_carta_jugador(index: int, jugador: Node) -> Vector2:
	var screen_size = get_viewport().size
	var jugador_index = jugadores.find(jugador)
	var espacio_entre_cartas = 82 # Espacio deseado entre cartas

	# Ajusta estas posiciones según tu diseño
	if jugador_index == 0: # Jugador 1
		return Vector2(screen_size.x * 0.1 + index * espacio_entre_cartas, screen_size.y * 0.8)
	elif jugador_index == 1: # Jugador 2
		return Vector2(screen_size.x * 0.1 + index * espacio_entre_cartas, screen_size.y * 0.1)

	return Vector2.ZERO
	
func disminuir_mazo():
	# Eliminar la última carta visual del mazo con una animación
	var cartas_mazo = get_tree().get_nodes_in_group("cartas_mazo")
	if cartas_mazo.size() > 0:
		var carta_a_eliminar = cartas_mazo[cartas_mazo.size() - 1]
		var tween = create_tween()
		tween.tween_property(carta_a_eliminar, "modulate:a", 1.0, 0.5)# Animar la transparencia
		tween.tween_callback(Callable(carta_a_eliminar, "queue_free")) # Liberar la carta después de la animación

func calcular_posicion_carta(index: int) -> Vector2:
	var screen_size = get_viewport().size
	var center_x = screen_size.x / 2
	var center_y = screen_size.y / 2

	var filas = 2
	var columnas = 4

	var espacio_x = 82
	var espacio_y = 133
	var cartas_colocadas = index

	var fila = cartas_colocadas / columnas
	var columna = cartas_colocadas % columnas

	var pos_x = center_x + (columna - (columnas / 2)) * espacio_x
	var pos_y = center_y + (fila - (filas / 2)) * espacio_y

	return Vector2(pos_x, pos_y)

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
