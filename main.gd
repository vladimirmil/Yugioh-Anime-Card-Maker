extends Control

# CARD TEXTURES
const cardNormal = preload("res://img/types/normal.png")
const cardEffect = preload("res://img/types/effect.png")
const cardFusion = preload("res://img/types/fusion.png")
const cardRitual = preload("res://img/types/ritual.png")
const cardSpell = preload("res://img/types/spell.png")
const cardTrap = preload("res://img/types/trap.png")
# LEVEL TEXTURES
const level1 = preload("res://img/levels/1.png")
const level2 = preload("res://img/levels/2.png")
const level3 = preload("res://img/levels/3.png")
const level4 = preload("res://img/levels/4.png")
const level5 = preload("res://img/levels/5.png")
const level6 = preload("res://img/levels/6.png")
const level7 = preload("res://img/levels/7.png")
const level8 = preload("res://img/levels/8.png")
const level9 = preload("res://img/levels/9.png")
const level10 = preload("res://img/levels/10.png")
const level11 = preload("res://img/levels/11.png")
const level12 = preload("res://img/levels/12.png")
# ATTRIBUTE TEXTURES
const darkAttr = preload("res://img/attributes/DARK.png")
const divinekAttr = preload("res://img/attributes/DIVINE.png")
const earthAttr = preload("res://img/attributes/EARTH.png")
const fireAttr = preload("res://img/attributes/FIRE.png")
const lightAttr = preload("res://img/attributes/LIGHT.png")
const waterAttr = preload("res://img/attributes/WATER.png")
const windAttr = preload("res://img/attributes/WIND.png")


# INPUT
onready var atkSetValue = $Control1/Control2/AtkLineEdit
onready var defSetValue = $Control1/Control2/DefLineEdit
onready var nameLineEdit = $Control1/Control2/NameLineEdit
onready var typeMenuButton = $Control1/Control2/TypeMenuButton
onready var openMenuButton = $TextureRectTop/OpenMenuButton
onready var attributeMenuButton = $Control1/Control2/AttributeMenuButton
onready var levelMenuButton = $Control1/Control2/LevelMenuButton
# ATK DEF OUTPUT
onready var atkValue = $CardTexture/AtkValueLabel
onready var defValue = $CardTexture/DefValueLabel
# IMAGE
onready var cardTexture = $CardTexture
onready var levelTexture = $CardTexture/LevelTexture
onready var attributeTexture = $CardTexture/AttributeTexture
onready var imageBtn = $Control1/Control2/ImageBtn
onready var imageList = $Control1/ImageList
onready var cardArtTexture = $CardTexture/CardArtTexture
onready var refreshArtworkListBtn = $Control1/RefreshArtworkListBtn
# FILE
onready var fileDialog = $OpenFileDialog
# SAVE
onready var saveBtn = $Control1/SaveBtn
# POPUP
onready var notificationDialog = $NotificationDialog


var cardArray : Array = []
var levelArray : Array = []
var attributesArray : Array = []
var saveFile : String = ""
var mainDirectory : String = ""
var savePath : String = ""
var cardArtworkPath : String = ""
var pathsArray : Array = []


func _ready() -> void:
	connectSignals()
	cardArray = [cardNormal, cardEffect, cardFusion, cardRitual, cardSpell, cardTrap]
	attributesArray = [darkAttr, divinekAttr, earthAttr, fireAttr, lightAttr, waterAttr, windAttr]
	levelArray = [
		level1,
		level2,
		level3,
		level4,
		level5,
		level6,
		level7,
		level8,
		level9,
		level10,
		level11,
		level12,
	]
	
	# Sets up file dialog starting directory and makes x button invisible
	fileDialog.get_close_button().visible = false
	fileDialog.window_title = ""
	fileDialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	notificationDialog.get_close_button().visible = false
	
	# Sets up directory paths
	mainDirectory = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/YugiohCardMaker"
	savePath = mainDirectory + "/Cards"
	cardArtworkPath = mainDirectory + "/Artwork"
	pathsArray = [mainDirectory, savePath, cardArtworkPath]
	
	# Creates folders in Documents if they do not exists
	var dir = Directory.new()
	for i in range(0, pathsArray.size(), 1):
		if dir.open(pathsArray[i]) != OK:
			dir.make_dir(pathsArray[i])
	
	# Init images
	on_new_type_id_pressed(0)
	on_attribute_id_pressed(0)
	on_level_id_pressed(0)
	
	getDirectoryContents(cardArtworkPath)


 # Hides attribute, level, atk and def when type is spell or trap
func cardVisibilityHandler(value : int) -> void:
	if value > 3:
		attributeTexture.visible = false
		levelTexture.visible = false
		atkValue.visible = false
		defValue.visible = false
		attributeMenuButton.disabled = true
		levelMenuButton.disabled = true
		atkSetValue.editable = false
		defSetValue.editable = false
	else:
		attributeTexture.visible = true
		levelTexture.visible = true
		atkValue.visible = true
		defValue.visible = true
		attributeMenuButton.disabled = false
		levelMenuButton.disabled = false
		atkSetValue.editable = true
		defSetValue.editable = true


# Adds file names to "imageList" itemList
func getDirectoryContents(path : String) -> void:
	imageList.clear()
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir(): # if not then it's a file, otherwise it's a folder
				imageList.add_item(file_name)
			file_name = dir.get_next()
	else:
		notificationDialog.dialog_text = "An error occurred when trying to access the path"
		notificationDialog.popup()


func connectSignals() -> void:
	typeMenuButton.get_popup().connect("id_pressed", self, "on_new_type_id_pressed")
	openMenuButton.get_popup().connect("id_pressed", self, "on_open_id_pressed")
	atkSetValue.connect("text_changed", self, "on_atk_text_changed")
	defSetValue.connect("text_changed", self, "on_def_text_changed")
	attributeMenuButton.get_popup().connect("id_pressed", self, "on_attribute_id_pressed")
	levelMenuButton.get_popup().connect("id_pressed", self, "on_level_id_pressed")
	imageBtn.connect("pressed", self, "on_image_btn_pressed")
	fileDialog.connect("file_selected", self, "on_file_selected")
	saveBtn.connect("pressed", self, "on_save_pressed")
	imageList.connect("item_selected", self, "on_image_item_list_selected")
	refreshArtworkListBtn.connect("pressed", self, "on_refresh_list_pressed")


# Changes texture and type of a card 
func on_new_type_id_pressed(value : int) -> void:
	cardVisibilityHandler(value)
	cardTexture.texture = cardArray[value]
	typeMenuButton.text = typeMenuButton.get_popup().get_item_text(value)


# Opens directory
func on_open_id_pressed(value : int) -> void:
	if value == 0:
		OS.shell_open(savePath)
	else:
		OS.shell_open(cardArtworkPath)


func on_atk_text_changed(value : String) -> void:
	atkValue.text = value


func on_def_text_changed(value : String) -> void:
	defValue.text = value


# Changes attribute texture
func on_attribute_id_pressed(value : int) -> void:
	attributeTexture.texture = attributesArray[value]
	attributeMenuButton.text = attributeMenuButton.get_popup().get_item_text(value)


# Changes level texture
func on_level_id_pressed(value : int) -> void:
	levelTexture.texture = levelArray[value]
	levelMenuButton.text = levelMenuButton.get_popup().get_item_text(value)


# Opens up file dialog for manualy selecting card artwork 
func on_image_btn_pressed() -> void:
	fileDialog.popup()


# Sets the texture of artwork when manualy selecting card artwork 
func on_file_selected(value : String) -> void:
	var img = Image.new()
	var tex = ImageTexture.new()
	img.load(value)
	tex.create_from_image(img)
	cardArtTexture.texture = tex


# Takes a screenshot of the card and saves it to Documents\YugiohCardMaker\Cards
func on_save_pressed() -> void:
	if nameLineEdit.text != "":
		saveFile = savePath + "/" + nameLineEdit.text + ".png"
		var region : Rect2 = Rect2(
			cardTexture.rect_position.x, 
			cardTexture.rect_position.y - 4, # -4? Godot bug?
			cardTexture.rect_size.x,
			cardTexture.rect_size.y
			)
		var image : Object = get_viewport().get_texture().get_data().get_rect(region)
		image.flip_y()
		if image.save_png(saveFile) == OK:
			notificationDialog.dialog_text = "Image saved succesifuly to " + savePath
		else:
			notificationDialog.dialog_text = "Error saving image"
		notificationDialog.popup()
		saveFile = ""
	else:
		notificationDialog.dialog_text = "Please enter card name"
		notificationDialog.popup()


# Changes card artwork when list item is pressed
func on_image_item_list_selected(value : int) -> void:
	var artPath : String = cardArtworkPath + "/" + imageList.get_item_text(value)
	on_file_selected(artPath)


func on_refresh_list_pressed() -> void:
	getDirectoryContents(cardArtworkPath)





