extends Control

export(String) var day

export(String) var minTemp
export(String) var maxTemp

export(Texture) var weatherIcon

func _process(_delta):
	$AllMargin/AllContent/DayMargin/Day.text = day
	$AllMargin/AllContent/IconMargin/Icon.texture = weatherIcon
	$AllMargin/AllContent/TempMargin/Temp.text = "Min " + minTemp + "°C" + " | " + "Max " + maxTemp + "°C"
