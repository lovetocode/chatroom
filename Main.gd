extends Control


const PORT = 3000
const MAX_USERS = 4

onready var chat_display = $RoomUI/ChatDisplay
onready var chat_input = $RoomUI/ChatInput
onready var user_name = $SetUp/UserName

var username = ""
var id 
var oldname = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	
func server_disconnected():
	chat_display.text += "Disconnected from surver\n"
	_on_LeaveButton_pressed()
	
func user_entered(id):
	chat_display.text += str(id) + "joined the room\n"
	
func user_exited(id):
	chat_display.text += str(id) + "left the room\n"
	
func enter_room():
	chat_display.text = "Successfully joined room\n"
	
	$SetUp/LeaveButton.show()
	$SetUp/JoinButton.hide()
	$SetUp/HostButton.hide()
	$SetUp/IPEnter.hide()

func _on_LeaveButton_pressed():
	get_tree().set_network_peer(null)
	chat_display.text += "Left room\n"
	
	$SetUp/LeaveButton.hide()
	$SetUp/JoinButton.show()
	$SetUp/HostButton.show()
	$SetUp/IPEnter.show()

func _on_JoinButton_pressed():
	var ip = $SetUp/IPEnter.text
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)
	OS.set_window_title("Chat Room - Client")


func _on_HostButton_pressed():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(host)
	enter_room()
	chat_display.text = "Room created\n"
	OS.set_window_title("Chat Room - Host")
	
func _on_ChatInput_text_entered(new_text):
	send_message()
	
func send_message():
	var msg = chat_input.text
	chat_input.text = ""
	if username == "":
		id = get_tree().get_network_unique_id()
		oldname = str(id)
	rpc("recieve message", id, msg)
	
sync func recieve_message(id, msg):
	chat_display.text += str(id) +  ": " + msg +"\n"
	

func _on_NameButton_pressed():
	if oldname == str(get_tree().get_network_unique_id()):
		pass
	username = user_name.text
	id = username
	chat_display.text = oldname + " changed to " + str(id) + "\n"
	user_name.text = ""
	oldname = username


