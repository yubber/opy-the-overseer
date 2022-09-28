#!mainFile "new.opy"
##########
# GLOBAL #
##########

### npc
globalvar techNPC
globalvar marketNPC
globalvar patrollerNo

globalvar sellingTech

### resources
# ui
globalvar resourceNames = [
	"minerals",
	"vespene gas",
	"sulfur",
	"lumber",
	"stone",
	"food"
]
globalvar resourceIcons = [
	abilityIconString(Hero.ECHO, Button.SECONDARY_FIRE),
	abilityIconString(Hero.PHARAH, Button.ABILITY_1),
	abilityIconString(Hero.MEI, Button.ABILITY_1),
	abilityIconString(Hero.ASHE, Button.ABILITY_2),
	abilityIconString(Hero.SIGMA, Button.ABILITY_2),
	abilityIconString(Hero.ROADHOG, Button.ABILITY_2)
]
globalvar resourceColors = [
	Color.SKY_BLUE,
	Color.LIME_GREEN,
	Color.YELLOW,
	Color.ORANGE,
	Color.GRAY,
	Color.ROSE
]

# deposits
globalvar depositPos
globalvar depositAmts
globalvar depositDespawn
globalvar i_deposit

# rarities
globalvar rarity
globalvar rarityPick

### overseer
globalvar overseerPos = vect(143.490, 4.150, 247.490)
globalvar overseerColor # = random.choice([Color.BLUE, Color.YELLOW])
globalvar overseerWants
globalvar exchangeRate

globalvar phaseTime

globalvar spawnCenter = vect(146.990, 6, 251.050)
globalvar defaultVect = vect(139, 5.500, -283)

globalvar orisaQuips = [
	"greetings, citizen.",
	"all hail the overseer.",
	"the overseer is watching you.",
	"may the overseer watch over you.",
	"carry on with your duties, citizen.",
	"it is a good day under the watch of the overseer.",
	"under the overseer, we are truly free."
]

globalvar i_init
# used in npc repos
globalvar global_temp_1
globalvar global_temp_2

##########
# PLAYER #
##########

### resources
playervar heldContents = [0 for x in resourceNames]
playervar stashContents = eventPlayer.heldContents
playervar heldCap
playervar stashCap
playervar money

playervar stashPos # used for npc bonking
playervar oldStashPos
playervar isCarryingStash

playervar resourceSel

# upgrades
playervar takeRange
playervar putRange

enum UPGRADES:
	TAKE,
	PUT,
	MOVE,
	HOLD,
	STASH

playervar upgrades

enum BEAMS:
	OFF = -1,
	TAKE,
	PUT

playervar beamTarget

enum TARGETS:
	NONE = -1,
	DEPOSIT,
	OVERSEER,
	STASH,
	MARKET

playervar targetType
playervar targetPos
playervar targetIndex
playervar beamPrompt
playervar targets
playervar activeBeam
playervar beamCheckCd

playervar naughty
playervar stealingMod
playervar interest
playervar loyalty

### npc
playervar npcFaceTarget

playervar aiCurrentAngle
playervar aiMoveDir
playervar aiFaceTarget
playervar aiOldPos

# players: used in finding initial spawn pos
playervar temp_1
playervar temp_2