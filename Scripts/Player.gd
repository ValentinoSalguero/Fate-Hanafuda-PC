extends Node

var mano : Array = []
var puntos : int = 0

func agregar_carta(carta):
	mano.append(carta)

func calcular_puntos():
	puntos = 0
	for carta in mano:
		puntos += carta.valor
	return puntos
