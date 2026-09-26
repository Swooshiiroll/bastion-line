extends RefCounted
## Sector definitions on a 32×16 grid of 48 px tiles (1536×768, the whole battlefield at 1600×900).
##
## `layout`: 16 rows of 32 characters, one per tile:
##   .  open floor (buildable)          #  wall / prop (not buildable)
##   H  high ground: towers +15% range  P  power node: towers +15% damage
##   R  rubble: not buildable until cleared for `rubble_cost` credits
##   =  lane    ~  sludge lane (slows ground enemies)    ^  shock lane (damages ground enemies)
##   G  switch gate: the lane tile where an entrance's routes fork
## Every lane character must lie on a route and every route cell must be a lane character
## (checked by the tests).
##
## `entrances`: one entry per warp gate, each a list of routes (axis-aligned waypoint lists in
## tile coordinates, first and last waypoints just off the grid). Routes of one entrance share
## their waypoints up to the fork (the G tile); a switch gate there picks which of them new
## arrivals take. Flyers ignore routes and fly straight from each route's start to its end.
##
## Each sector keeps its original 20×12 design in the top-left corner and extends into the rest.
## Sectors are pure maps: layout and theme. Shields and run length come from the difficulty mode,
## enemy strength from the round number, and every run starts with the same credits.
## Internal ids (meadow, canyon, crossroads) predate the sci-fi names and are kept for old saves.

const ORDER := ["meadow", "canyon", "delta", "crossroads", "foundry", "singularity"]

const MAPS := {
	"meadow": {
		"name": "Outpost Theta",
		"blurb": "A quiet frontier outpost with one long, winding supply lane. A good place to learn what high ground, power nodes and rubble do.",
		"theme": "meadow",
		"layout": [
			"............#.................#.",
			".......#..........#.......#.....",
			"=====................#..........",
			"....=....======.................",
			"....=....=....=..#.......=======",
			".#..=....=.HH.=.RR.......=......",
			"....=..P.=.HH.=.R........=......",
			"....=....=....=..........=..RR..",
			"....======....=.......HH.=..R...",
			"#.............======.....=......",
			".RR........#.......=.....=....#.",
			"................#..=..P..=......",
			"............#......=.....=......",
			"...#...............=======......",
			"........#........#..........R...",
			".............................#..",
		],
		"entrances": [
			[[Vector2i(-1, 2), Vector2i(4, 2), Vector2i(4, 8), Vector2i(9, 8), Vector2i(9, 3),
				Vector2i(14, 3), Vector2i(14, 9), Vector2i(19, 9), Vector2i(19, 13), Vector2i(25, 13),
				Vector2i(25, 4), Vector2i(32, 4)]],
		],
	},
	"canyon": {
		"name": "Red Rift",
		"blurb": "A causeway zig-zags across a Martian rift. Sludge pools slow the turns; flyers cut straight across.",
		"theme": "canyon",
		"layout": [
			"....#.................#.........",
			"==================..............",
			".....#...HH......=.....=~~~~=...",
			"...P.....H.......=.....=....=...",
			"..~~~~============.....=....=...",
			"..=.........HH.........=.HH.=...",
			"#.=..R......HH....#....=.HH.=.#.",
			"..============~~~~.....=....=...",
			".....#...........=.....=.P..=...",
			"........P..R.....=.....=....=.R.",
			"........#........===~~~=....=...",
			"...#...............##.......=...",
			"......H.........R.......#...=...",
			"..#.........#...............====",
			"........R.........P.............",
			"....#..........#...........#....",
		],
		"entrances": [
			[[Vector2i(-1, 1), Vector2i(17, 1), Vector2i(17, 4), Vector2i(2, 4), Vector2i(2, 7),
				Vector2i(17, 7), Vector2i(17, 10), Vector2i(23, 10), Vector2i(23, 2), Vector2i(28, 2),
				Vector2i(28, 13), Vector2i(32, 13)]],
		],
	},
	"delta": {
		"name": "Cryo Delta",
		"blurb": "The lane forks around a frozen island and rejoins. A switch gate chooses the short north run or the long, slushy south one.",
		"theme": "delta",
		"layout": [
			"...#.........#.........#......#.",
			"..........R..................#..",
			"....=================.....R.....",
			".R..=....#..........=...........",
			"....=...P.....R.....=...........",
			"====G...............=....H......",
			"....=......HH.......=....H..#...",
			"#...=......HH.......=======....#",
			"....=...............=.....=.....",
			"....=....#....P.....=.....=..P..",
			"....=...............=.....=.R...",
			"....=.......#.......=.....=.....",
			"....=~~~~~~~~~=======.....=.....",
			"..R.......#...............======",
			"......#..........R......#.......",
			"............#.................#.",
		],
		"entrances": [
			[
				[Vector2i(-1, 5), Vector2i(4, 5), Vector2i(4, 2), Vector2i(20, 2), Vector2i(20, 7),
					Vector2i(26, 7), Vector2i(26, 13), Vector2i(32, 13)],
				[Vector2i(-1, 5), Vector2i(4, 5), Vector2i(4, 12), Vector2i(20, 12), Vector2i(20, 7),
					Vector2i(26, 7), Vector2i(26, 13), Vector2i(32, 13)],
			],
		],
	},
	"crossroads": {
		"name": "Nexus Station",
		"blurb": "Two warp gates feed one lane into the station core. Shock strips soften them up before the merge, and power nodes flank it.",
		"theme": "crossroads",
		"layout": [
			"..#.............#.........#.....",
			".........#.........#..........#.",
			"==^^^===....=====...............",
			".......=....=...=...............",
			"...#...=.HH.=...=.......========",
			".......=....=P..=.......=......#",
			".......======...=.......=..P....",
			"..........=P....=..HH...=.......",
			".....R....=.....=..HH...=...R...",
			"..........=.....=.......=.......",
			"....#.....=.....=...P...=...#...",
			"..........=.....=========.......",
			"..........=.......R.........#...",
			"=====^^^===......#......R.......",
			"....#........P.........#........",
			".......#...........#..........#.",
		],
		"entrances": [
			[[Vector2i(-1, 2), Vector2i(7, 2), Vector2i(7, 6), Vector2i(12, 6), Vector2i(12, 2),
				Vector2i(16, 2), Vector2i(16, 11), Vector2i(24, 11), Vector2i(24, 4), Vector2i(32, 4)]],
			[[Vector2i(-1, 13), Vector2i(10, 13), Vector2i(10, 6), Vector2i(12, 6), Vector2i(12, 2),
				Vector2i(16, 2), Vector2i(16, 11), Vector2i(24, 11), Vector2i(24, 4), Vector2i(32, 4)]],
		],
	},
	"foundry": {
		"name": "Foundry Nine",
		"blurb": "A cramped plant choked with scrap. The gate sends hostiles over the shock conveyors or round the long loop. Clear rubble to make room.",
		"theme": "foundry",
		"layout": [
			"#.....RR....#...RR........R..#..",
			"====..R.....R..........RR.......",
			"...=...RR...P...R.........#.....",
			".R.=....H.......RR.....P........",
			"...=..R.....R..........R....R...",
			"...G==^^^^^^^====..........RR...",
			"...=.RR...P.R...=.R.......======",
			"#..=..R.....=====.........=.....",
			"...=...H....=...=....H....=..R..",
			"...=..R..P..=...=...RR....=.....",
			"...=........=...=....P....=..R..",
			"...=..RR....=...=.........=.....",
			"...=........=...=...R.....=..#..",
			".R.=....P...=...===========..R..",
			"...==========..R......RR....#...",
			".R....#.....RR..........R......#",
		],
		"entrances": [
			[
				[Vector2i(-1, 1), Vector2i(3, 1), Vector2i(3, 5), Vector2i(16, 5), Vector2i(16, 13),
					Vector2i(26, 13), Vector2i(26, 6), Vector2i(32, 6)],
				[Vector2i(-1, 1), Vector2i(3, 1), Vector2i(3, 5), Vector2i(3, 14), Vector2i(12, 14),
					Vector2i(12, 7), Vector2i(16, 7), Vector2i(16, 13), Vector2i(26, 13), Vector2i(26, 6),
					Vector2i(32, 6)],
			],
		],
	},
	"singularity": {
		"name": "Singularity Array",
		"blurb": "Two warp gates, each with its own fork and switch gate, converge on the core. Long lanes, but they all meet at one choke point.",
		"theme": "singularity",
		"layout": [
			"##......#......#.......#.....#.#",
			"=====G=================.........",
			".....=.RR..#..........=......#..",
			"..#..=.........P......=..P......",
			".....=....R.....#.....=.........",
			".....============.....=...#.....",
			".R.......H......=.....=.......R.",
			"#........P......============....",
			".R.......H......=.....=....=....",
			"................=.....=....=..#.",
			".....============.....=....=....",
			"..#..=....R.....#.....=....=====",
			".....=.........P......=..P...#..",
			".....=.RR..#..........=.........",
			"=====G=================.........",
			"##......#..RR..#.......#.....#.#",
		],
		"entrances": [
			[
				[Vector2i(-1, 1), Vector2i(5, 1), Vector2i(22, 1), Vector2i(22, 7), Vector2i(27, 7),
					Vector2i(27, 11), Vector2i(32, 11)],
				[Vector2i(-1, 1), Vector2i(5, 1), Vector2i(5, 5), Vector2i(16, 5), Vector2i(16, 7),
					Vector2i(27, 7), Vector2i(27, 11), Vector2i(32, 11)],
			],
			[
				[Vector2i(-1, 14), Vector2i(5, 14), Vector2i(22, 14), Vector2i(22, 7), Vector2i(27, 7),
					Vector2i(27, 11), Vector2i(32, 11)],
				[Vector2i(-1, 14), Vector2i(5, 14), Vector2i(5, 10), Vector2i(16, 10), Vector2i(16, 7),
					Vector2i(27, 7), Vector2i(27, 11), Vector2i(32, 11)],
			],
		],
	},
}
