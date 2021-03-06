extends Node2D
class_name GameMode

export (String) var default_character
var spawn_list = {}

func _ready():
	game_chat._enable()

	if (get_tree().is_network_server()):
		network.connect("player_added", self, "_on_player_added")
		network.connect("player_removed", self, "_on_player_removed")

	game_map._load_map()

### --- Events

func _on_player_added(pinfo):
	print("Spawning player ", pinfo.name, " (ID ", pinfo.id, ")")
	spawn_player(pinfo)

func _on_player_removed(pinfo):
	print("Removing player ", pinfo.name, " (ID ", pinfo.id, ")")
	despawn_player(pinfo)

### --- Remote functions

remote func spawn_player(pinfo):
	pinfo.character = default_character

	if (get_tree().is_network_server() && pinfo.id != 1):
		for id in network.players:
			if (id != pinfo.id):
				rpc_id(pinfo.id, "spawn_player", network.players[id])

			if (id != 1):
				rpc_id(id, "spawn_player", pinfo)

	# Create a character
	var pclass = load(pinfo.character)

	var pchar = pclass.instance()
	pchar._setup(pinfo)
	pchar.position = spawn_list[0].world_position

	add_child(pchar)

remote func despawn_player(pinfo):
	if (get_tree().is_network_server()):
		for id in network.players:
			if (id == pinfo.id || id == 1):
				continue

			rpc_id(id, "despawn_player", pinfo)

	# Try to locate the player actor
	var player_node = get_node(str(pinfo.id))
	if (!player_node):
		print("Cannot remove invalid node from tree")
		return

	player_node.queue_free()
