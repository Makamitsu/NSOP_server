extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 10

var currentPlayers: Array

func _ready():
	StartServer()
	VisualServer.render_loop_enabled = false

func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

remote func pos_updated(new_pos):
	var player_id = get_tree().get_rpc_sender_id()
	rpc("player_moved", player_id, new_pos)

remote func try_to_kill(killer, victims):
	# Test if kill is possible, auto accept for now
	
	
	rpc("player_killed", killer, victims)

func _peer_connected(player_id):
	print("User " +str(player_id)+" connected")
	assert(not currentPlayers.has(player_id))
	
	rpc_id(player_id, "set_id_other_ids", player_id, currentPlayers)
	currentPlayers.append(player_id)
	rpc("player_joined", player_id)

func _peer_disconnected(player_id):
	currentPlayers.remove(player_id)
	print("User " +str(player_id)+" disconnected")
