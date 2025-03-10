extends Node

var mano : Array = []
var puntos : int = 0
var posicion : Vector2 = Vector2()  # Crear la propiedad de posición

# Función para agregar una carta al jugador
func agregar_carta(carta):
	mano.append(carta)

# Función para calcular los puntos del jugador
func calcular_puntos():
	puntos = 0
	for carta in mano:
		puntos += carta.valor
	return puntos

# Función para obtener la posición del jugador
func get_posicion():
	return posicion
