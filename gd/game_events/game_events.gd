extends Node

@warning_ignore("unused_signal")
signal event_emited(event: GameEvent)

# Player events
@warning_ignore("unused_signal")
signal player_take_damage(event: PlayerTakeDamageEvent)
@warning_ignore("unused_signal")
signal player_take_lp(event: PlayerTakeLPEvent)
@warning_ignore("unused_signal")
signal player_heal(event: PlayerHealEvent)
@warning_ignore("unused_signal")
signal player_reduce_lp(event: PlayerReduceLPEvent)
@warning_ignore("unused_signal")
signal player_end_turn(event: PlayerEndTurnEvent)
@warning_ignore("unused_signal")
signal player_play_card(event: PlayerPlayCardEvent)

# Combat events
@warning_ignore("unused_signal")
signal combat_end(event: CombatEndEvent)

# Enemy events
@warning_ignore("unused_signal")
signal enemy_move_strip_panties(event: EnemyMoveStripPantiesEvent)
