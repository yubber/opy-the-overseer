#!mainFile "new.opy"

# total number of deposits
#!define DepositNo 12
#!define ResourceNo 6
#!define ResourceScalar 1

# global temp values
#!define NPCRepos_1 techNPC.temp_1
#!define NPCRepos_2 techNPC.temp_2

#!define Gltemp1 global_temp_1
#!define Gltemp2 global_temp_2

#!define humanPlayers getAllPlayers()
# since target index will never exceed last player slot, optimized out
# [gamer for gamer in getAllPlayers() if not gamer.isDummy()]
#!define PlayerSlots 8

#!define orisaRaycastBlackMagic if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS): continue
#!define SpaceSpam "\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;"
# spacelite len at 5 for progress bar
#!define SpaceLite "\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;\&fullwidth_space;"
#!define HudOffset (-0.3)

#!define BeamOnPlayer eventPlayer
# eventPlayer + worldVector(vect(-0.225, 1.82, 0), eventPlayer, Transform.ROTATION)
#!define BeamOnTarget eventPlayer.beamTarget

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
	Color.GREEN,
	Color.YELLOW,
	Color.ORANGE,
	Color.GRAY,
	Color.ROSE
]

globalvar allTargets

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
playervar takeSpeed
playervar putRange
playervar putSpeed

enum UPGRADES:
	TAKE,
	PUT,
	MOVE,
	HOLD,
	STASH

playervar upgrades = [0, 0, 0, 0, 0]

enum BEAMS:
	OFF = -1,
	TAKE,
	PUT

playervar beamType

# currently active beam so player can turn away
playervar beamTarget
playervar beamTargetType
playervar beamTargetIndex
playervar moveAmt

enum TARGETS:
	NONE = -1,
	DEPOSIT,
	OVERSEER,
	STASH,
	MARKET

# current facing target
playervar targetType
playervar targetPos
playervar targetIndex
playervar beamPrompt
playervar targets

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