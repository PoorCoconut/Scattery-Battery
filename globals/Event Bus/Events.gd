extends Node

signal player_hp_updated(current_hp, max_hp)
signal player_max_hp_updated(max_hp)

signal mod_equipped(category: String, id: String)
signal mod_unequipped(category: String, id: String)

## Enemies must emit this on death (Events.enemy_died.emit()) for Siphon Drill to work.
signal enemy_died
