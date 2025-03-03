extends Node2D

var mes : String = ""
var valor : int = 0
var sprite : Sprite2D

func _ready():
	sprite = $Sprite2D
	actualizar_imagen()

func inicializar(nuevo_mes : String, nuevo_valor : int):
	mes = nuevo_mes
	valor = nuevo_valor
	actualizar_imagen()

func actualizar_imagen():
	if sprite and mes != "" and valor > 0: 
		var ruta = "res://Images/Cards/" + mes + str(valor) + ".png"
		if ResourceLoader.exists(ruta):
			sprite.texture = load(ruta)
		else:
			print("Imagen no encontrada: ", ruta)
