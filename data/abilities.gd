extends RefCounted
## Player abilities. Cooldowns only run while a wave is in progress; abilities can only be cast then.
## Meteor damage is multiplied by the wave's HP scale so it stays relevant late in the game.

const ORDER := ["meteor", "warp"]

const ABILITIES := {
	"meteor": {
		"name": "Orbital Strike", "short": "Orbital", "key": "Q",
		"cooldown": 45.0, "damage": 110.0, "radius": 85.0, "delay": 0.9,
		"blurb": "Call an orbital laser onto a target area. Heavy damage that ignores armor and hits flyers. Grows stronger each round.",
	},
	"warp": {
		"name": "Chrono Field", "short": "Chrono", "key": "W",
		"cooldown": 70.0, "slow": 0.6, "duration": 5.0,
		"blurb": "Slow every enemy in the sector by 60% for 5 seconds. Bosses resist half of it.",
	},
}
