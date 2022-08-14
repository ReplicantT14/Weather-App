extends Control

#preloading these scenese so I can make nodes out of them later on
var Hourly = preload("res://Hourly.tscn")
var Daily = preload("res://DailyWeather.tscn")

var currentTime
var currentDateAndTime

var click_mouse_poition
onready var options = $Options

enum OptionsIds{
	SHOW_HOURLY,
	SHOW_DAILY,
	QUIT
}

#true - show hourly/daily nodes
#false - hide hourly/daily nodes 
var showHourly = true
var showDaily = true

#string that represents the API used for requesting AccuWeather data
var API = null

func _ready():
	#setting the visibility of main nodes and transparency of the whole windows
	get_tree().get_root().set_transparent_background(true)
	$Content/ScrollContainer.visible = showHourly
	$Content/Daily.visible = showDaily
	$MovingBackground.hide()
	$Content/ScrollContainer.get_h_scrollbar().rect_scale.x = 0
	$Content.visible = false
	$LineEdit.visible = false
	$Moving/MovingArea.visible = false
	$ScrollingArea.visible = false
	
	#checking if the options file exists and reading 
	var file = File.new()
	file.open("res://options.dat", File.READ)
	if (file.is_open()):
		API = file.get_line()
		showHourly = bool(int(file.get_line()))
		showDaily = bool(int(file.get_line()))
		file.close()
	
	else:
		$LineEdit.visible = true
	
	if (API != null):
		$Content.visible = true
		start_everything()
	
	#creating the context menu items
	options.add_check_item("Show hourly weather", OptionsIds.SHOW_HOURLY)
	options.set_item_checked(OptionsIds.SHOW_HOURLY, showHourly)
	options.add_check_item("Show daily weather", OptionsIds.SHOW_DAILY)
	options.set_item_checked(OptionsIds.SHOW_DAILY, showDaily)
	options.add_item("Quit", OptionsIds.QUIT)

func _input(event):
	#opening the context menu
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT):
		click_mouse_poition = get_global_mouse_position()
		options.popup(Rect2(click_mouse_poition.x, click_mouse_poition.y, options.rect_size.x, options.rect_size.y))

func _process(_delta):
	#handles the text API input
	if (API == null):
		if (Input.is_action_just_pressed("ui_accept")):
			API = $LineEdit.text
			$LineEdit.visible = false
			$Content.visible = true
			$HideHints.start()
			$Moving/MovingArea.visible = true
			$ScrollingArea.visible = true
	
	else:
		$Content/ScrollContainer.visible = showHourly
		$Content/Daily.visible = showDaily
		currentDateAndTime = OS.get_datetime()
	
		var hours
		var minutes
		#by default, if it is, for instance, 09:07 Godot will see it as 9:7
		#these if statements fix that
		if (currentDateAndTime["hour"] < 10):
			hours = "0" + str(currentDateAndTime["hour"])
		else:
			hours = str(currentDateAndTime["hour"])
		if (currentDateAndTime["minute"] < 10):
			minutes = "0" + str(currentDateAndTime["minute"])
		else:
			minutes = str(currentDateAndTime["minute"])
	
		$Content/CurrentWeather.currentTime = hours + ":" + minutes
	
		match (currentDateAndTime["month"]):
			1:
				$Content/CurrentWeather.currentDate = "January " + str(currentDateAndTime["day"])
			2:
				$Content/CurrentWeather.currentDate = "February  " + str(currentDateAndTime["day"])
			3:
				$Content/CurrentWeather.currentDate = "March " + str(currentDateAndTime["day"])
			4:
				$Content/CurrentWeather.currentDate = "April " + str(currentDateAndTime["day"])
			5:
				$Content/CurrentWeather.currentDate = "May " + str(currentDateAndTime["day"])
			6:
				$Content/CurrentWeather.currentDate = "June " + str(currentDateAndTime["day"])
			7:
				$Content/CurrentWeather.currentDate = "July " + str(currentDateAndTime["day"])
			8:
				$Content/CurrentWeather.currentDate = "August " + str(currentDateAndTime["day"])
			9:
				$Content/CurrentWeather.currentDate = "September " + str(currentDateAndTime["day"])
			10:
				$Content/CurrentWeather.currentDate = "October " + str(currentDateAndTime["day"])
			11:
				$Content/CurrentWeather.currentDate = "November " + str(currentDateAndTime["day"])
			12:
				$Content/CurrentWeather.currentDate = "December " + str(currentDateAndTime["day"])

#function that starts everything
func start_everything():
	accuweather_current()
	create_hourly_weather_nodes()
	$CurrentAndHourlyTimer.start()
	create_daily_weather_nodes()
	$DailyTimer.start()

#deletes old Hourly nodes (if they exist) and calls accuweather_hourly() to create new ones
func create_hourly_weather_nodes():
	if ($Content/ScrollContainer/Hourly.get_child_count() != 0):
		for child in $Content/ScrollContainer/Hourly.get_children():
			$Content/ScrollContainer/Hourly.remove_child(child)
			child.queue_free()
	accuweather_hourly()

#deletes old Daily nodes (if they exist) and calls accuweather_daily() to create new ones
func create_daily_weather_nodes():
	if ($Content/Daily.get_child_count() != 0):
		for child in $Content/Daily.get_children():
			$Content/Daily.remove_child(child)
			child.queue_free()
	accuweather_daily()

#making a new http request node, requesting data and calling current_weather_api
func accuweather_current():
	var accuWeatherCurrent = HTTPRequest.new()
	add_child(accuWeatherCurrent)
	accuWeatherCurrent.connect("request_completed", self, "current_weather_api")
	var requestAPI = "http://dataservice.accuweather.com/currentconditions/v1/298198?apikey=" + API + "%20&details=true"
	var errorCurrent = accuWeatherCurrent.request(requestAPI)
	
	if (errorCurrent != OK):
		var errorLabel = Label.new()
		add_child(errorLabel)
		errorLabel.text = "There has been an error while requesting data"

#making a new http request node, requesting data and calling hourly_weather_api
func accuweather_hourly():
	var accuWeatherHourly = HTTPRequest.new()
	add_child(accuWeatherHourly)
	accuWeatherHourly.connect("request_completed", self, "hourly_weather_api")
	var requestAPI = "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/298198?apikey=" + API + "%20&details=true&metric=true"
	var errorHourly = accuWeatherHourly.request(requestAPI)
	
	if (errorHourly != OK):
		var errorLabel = Label.new()
		add_child(errorLabel)
		errorLabel.text = "There has been an error while requesting data"

#making a new http request node, requesting data and calling daily_weather_api
func accuweather_daily():
	var accuWeatherDaily = HTTPRequest.new()
	add_child(accuWeatherDaily)
	accuWeatherDaily.connect("request_completed", self, "daily_weather_api")
	var requestAPI = "http://dataservice.accuweather.com/forecasts/v1/daily/5day/298198?apikey=" + API + "&details=true&metric=true"
	var errorDaily = accuWeatherDaily.request(requestAPI)
	
	if (errorDaily != OK):
		var errorLabel = Label.new()
		add_child(errorLabel)
		errorLabel.text = "There has been an error while requesting data"

#parsing the body of the response as json
func current_weather_api(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var apiResult = json.result[0]
	$Content/CurrentWeather.currentTemp = str(int(apiResult["Temperature"]["Metric"]["Value"]))
	$Content/CurrentWeather.bodyTemp = str(int(apiResult["RealFeelTemperature"]["Metric"]["Value"]))
	#geting the name and path of the correct weather icon to show
	var iconPath = "res://Icons/" + str(apiResult["WeatherIcon"]) + "-s.png"
	#loading the weather icon
	var icon = load(iconPath)
	$Content/CurrentWeather.weatherIcon = icon

func hourly_weather_api(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	#scrollHbox var is used as a parent node later to create children hourly nodes to
	var scrollHbox = get_node("Content/ScrollContainer/Hourly")
	#there is weather for the next 12 hours given for free through the AccuWeather API
	#each loop is for 1 hour
	for x in 12:
		var apiResult = json.result[x]
		#hourly is an instance of the preloaded scene Hourly and than added as a child
		var hourly = Hourly.instance()
		scrollHbox.add_child(hourly)
		hourly.temp = str(int(apiResult["Temperature"]["Value"]))
		hourly.bodyTemp = str(int(apiResult["RealFeelTemperature"]["Value"]))
		var iconPath = "res://Icons/" + str(apiResult["WeatherIcon"]) + "-s.png"
		var icon = load(iconPath)
		hourly.weatherIcon = icon
		var time = apiResult["DateTime"]
		#the DateTime key in the json file contains more than just the time
		#with the substr I am just taking the time portion of the whole value
		hourly.time = time.substr(11, 5)

#the same from hourly_weather_api applies here
func daily_weather_api(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var HBox = get_node("Content/Daily")
	var result = json.result["DailyForecasts"]
	for x in range(5):
		var apiResult = result[x]
		var day
		var daily = Daily.instance()
		HBox.add_child(daily)
		var dayInt = OS.get_datetime()["weekday"]
		dayInt += x
		if (dayInt >= 7):
			var remainder = dayInt - 7
			dayInt = 0 + remainder
		match (dayInt):
			0:
				day = "Monday"
			1:
				day = "Tuesday"
			2:
				day = "Wednesday"
			3:
				day = "Thursday"
			4:
				day = "Friday"
			5:
				day = "Saturday"
			6:
				day = "Sunday"
		daily.day = day
		var iconPath = "res://Icons/" + str(apiResult["Day"]["Icon"]) + "-s.png"
		var icon = load(iconPath)
		daily.weatherIcon = icon
		daily.minTemp = str(int(apiResult["Temperature"]["Minimum"]["Value"]))
		daily.maxTemp = str(int(apiResult["Temperature"]["Maximum"]["Value"]))

#when an item from the context menu is clicked, it's ID is parsed here
func _on_Options_id_pressed(id):
	match (id):
		OptionsIds.SHOW_HOURLY:
			showHourly = !showHourly
			options.set_item_checked(OptionsIds.SHOW_HOURLY, showHourly)
		OptionsIds.SHOW_DAILY:
			showDaily = !showDaily
			options.set_item_checked(OptionsIds.SHOW_DAILY, showDaily)
		OptionsIds.QUIT:
			#when the QUIT button is clicked, the options.dat file is deleted and new one created with new data
			var dir = Directory.new()
			dir.remove("res://options.dat")
			var file = File.new()
			file.open("res://options.dat", File.WRITE)
			if (file.is_open()):
				file.store_line(API)
				file.store_line(str(int(showHourly)))
				file.store_line(str(int(showDaily)))
				file.close()
			get_tree().quit()

#timeout event that happens every hour (3600 seconds)
#every time it happens old nodes get deleted, new ones get created and the timer is strarted again
func _on_CurrentAndHourlyTimer_timeout():
	accuweather_current()
	create_hourly_weather_nodes()
	$CurrentAndHourlyTimer.start()

#timeout event that hides hints after 3.5 seconds if there is no options.dat file to be read
func _on_HideHints_timeout():
	$ScrollingArea.visible = false
	$Moving/MovingArea.visible = false
	start_everything()

#timeout event that happens every 12 hours (43200 seconds)
func _on_DailyTimer_timeout():
	create_daily_weather_nodes()
	$DailyTimer.start()
