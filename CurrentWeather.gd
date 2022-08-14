extends Control

export(String) var currentTime
export(String) var currentDate

export(String) var currentTemp
export(String) var bodyTemp

export(Texture) var weatherIcon

func _process(_delta):
	$AllElements/MarginTime/TimeContainer/Time.text = currentTime
	$AllElements/MarginTime/TimeContainer/Date.text = currentDate
	$AllElements/MarginWeather/WeatherContainer/CurrTemp.text = currentTemp + "°C"
	$AllElements/MarginWeather/WeatherContainer/BodyTemp.text = "Body feel " + bodyTemp + "°C"
	$AllElements/MarginIcon/Icon.texture = weatherIcon

