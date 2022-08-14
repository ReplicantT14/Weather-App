extends Control

export(String) var time

export(String) var temp
export(String) var bodyTemp

export(Texture) var weatherIcon

func _process(_delta):
	$AllElements/AllElements/TimeMargin/Time.text = time
	$AllElements/AllElements/IconMargin/Icon.texture = weatherIcon
	$AllElements/AllElements/TempMargin/Temp.text = temp + "°C" + " | " + "Body " + bodyTemp + "°C"
