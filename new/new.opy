settings {
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "swapTeamsAfterMatch": false,
        "ffaSlots": 8,
        "returnToLobby": "never",
        "mapRotation": "afterGame",
        "spectatorSlots": 12
    },
    "gamemodes": {
        "ffa": {
            "scoreToWin": 20,
            "enableEnemyHealthBars": false,
            "gamemodeStartTrigger": "immediately",
			"enabledMaps": [
                "oasisCityCenter"
            ]
        },
        "general": {
            "heroLimit": "off"
        }
    },
    "heroes": {
        "allTeams": {
            "echo": {
                "enablePassive": false
            },
            "general": {
                "enableMelee": false,
                "damageDealt%": 10,
                "ultDuration%": 25,
                "ultGen%": 10,
                "combatUltGen%": 0,
                "passiveUltGen%": 0,
                "abilityCooldown%": 500,
                "enablePrimaryFire": false
            }
        }
    }
}

#!include "newvars.opy"

# bindings
# crouch - stash pickup
# reload - dump
# interact - npc
# ability 1 - sprint
# ability 2 - next resource
# ult - prev resource
# melee - report

# total number of deposits
#!define DepositNo 12
#!define ResourceNo 6

# global temp values
#!define Gltemp1 global_temp_1
#!define Gltemp2 global_temp_2

#!define BeamOnPlayer eventPlayer + worldVector(vect(-0.225, 1.82, 0), eventPlayer, Transform.ROTATION_AND_TRANSLATION)
#!define BeamOnTarget eventPlayer.beamTarget + Vector.UP

def moveNPCs(): # must be called at the beginning of a rule because of goto rule start
	wait(0.064)
	Gltemp2 = random.uniform(5.205, 72)
	Gltemp2 = 3 + (0.028 * Gltemp2 ** 3 + -3.008 * Gltemp2 ** 2 + 108 * Gltemp2) / 72 + 0.500 * Gltemp2
	Gltemp1 = spawnCenter + angleToDirection(random.uniform(0,359.99), 0) * Gltemp2
	Gltemp2 = raycast(Gltemp1, Gltemp1 + 10 * Vector.DOWN, [], [], false).getHitPosition()
	if distance(Gltemp1, Gltemp2) <= 0.25:
		goto RULE_START
	Gltemp2 = nearestWalkablePosition(Gltemp2)

	if distance(Gltemp2, vect(7.940, 26.980, 195.610)) <= 120 \
		or distance(Gltemp2, vect(86.150, 23.600, 113.380)) <= 120 \
		or any([distance(x.stashPos, Gltemp2) < 8 for x in getAllPlayers()].exclude(0)) \
		or any([distance(x, Gltemp2) < 5 for x in depositPos.exclude(defaultVect)]):
			goto RULE_START

	# if tech tped already
	if techNPC.hasStatusEffect(Status.ROOTED):
		if distance(Gltemp2, techNPC.getPosition()) < 8:
			goto RULE_START
		marketNPC.teleport(Gltemp2)
		techNPC.clearStatusEffect(Status.ROOTED)
	else:
		techNPC.teleport(Gltemp2)
		techNPC.setStatusEffect(null, Status.ROOTED, 10)

def getTakeTarget(): # temp_2 is list of candidate pos, temp_1 is output
	eventPlayer.temp_1 = sorted([x for x in eventPlayer.temp_2 \
		if distance(x, eventPlayer) < eventPlayer.takeRange \
		and eventPlayer.isInViewAngle(x, 90) \
		and isInLoS(eventPlayer.getEyePosition(), x, BarrierLos.PASS_THROUGH_BARRIERS)],
		lambda y: angleBetweenVectors(eventPlayer.getFacingDirection(), y - eventPlayer.getPosition()))[0]

rule "global init":
	# disableInspector()
	disableGamemodeCompletion()
	disableScoring()
	setMatchTime(1)
	wait(1.2)
	setMatchTime(4*60+20)
	wait()
	pauseMatchTime()

	patrollerNo = createWorkshopSetting(int[1:9], "difficulty", "number of patrolling orisas", 6, 0)

	### deposits
	for i_init in range(DepositNo):
		depositAmts[i_init] = null
		depositPos[i_init] = null
		depositDespawn[i_init] = 130
		createEffect(getAllPlayers(), Effect.ORB, evalOnce(resourceColors[i_init % ResourceNo]), depositPos[evalOnce(i_init % ResourceNo)] + Vector.UP,
			0.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
		createEffect(getAllPlayers(), Effect.LIGHT_SHAFT, resourceColors[evalOnce(i_init % ResourceNo)], depositPos[evalOnce(i_init % ResourceNo)] + Vector.DOWN * 15,
			0.5 + 0.001 * depositAmts[evalOnce(i_init % ResourceNo)], EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

		# createInWorldText(getAllPlayers(), "{} {}: {}".format(evalOnce(resourceIcons[i_init % ResourceNo]), evalOnce(resourceNames[i_init % ResourceNo]), floor(depositAmts[evalOnce(i_init % ResourceNo)])),
		# 	depositPos[evalOnce(i_init % ResourceNo)] + 1.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
		createInWorldText(getAllPlayers(), "{} {}: {}".format(resourceIcons[evalOnce(i_init % ResourceNo)], resourceNames[evalOnce(i_init % ResourceNo)], floor(depositAmts[evalOnce(i_init % ResourceNo)])),
			depositPos[evalOnce(i_init % ResourceNo)] + 1.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
		wait()

	### overseer
	overseerColor = random.choice([Color.BLUE, Color.YELLOW])
	createEffect(getAllPlayers(), Effect.CLOUD, overseerColor, overseerPos + Vector.UP, 3, EffectReeval.VISIBILITY)
	createEffect(getAllPlayers(), Effect.GOOD_AURA, overseerColor, overseerPos + Vector.UP, 3 + 0.5 * sinDeg(getTotalTimeElapsed()), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	createIcon(getAllPlayers(), overseerPos + Vector.UP, Icon.EYE, IconReeval.VISIBILITY, overseerColor, false)
	createInWorldText(getAllPlayers(), "THE OVERSEER", overseerPos, 1.75, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)

	### rarities
	i_init = 16
	# 0-5
	rarity = [i_init, i_init, i_init, i_init, i_init, i_init]

	rarityPick[0] = -1
	for i_init in range(1, 7):
		rarityPick[i_init] = 16 * i_init
		wait()

	sellingTech = -1
	createDummy(random.choice([Hero.BRIGITTE, Hero.TORBJORN, Hero.SYMMETRA]), Team.ALL, -1, defaultVect, Vector.DOWN)
	techNPC = getLastCreatedEntity()
	techNPC.startForcingName("technician")

	wait()

	createDummy(random.choice([Hero.BAPTISTE, Hero.ANA, Hero.SOMBRA]), Team.ALL, -1, defaultVect, Vector.DOWN)
	marketNPC = getLastCreatedEntity()
	marketNPC.startForcingName("black market trader")

	for i_init in range(patrollerNo):
		createDummy(Hero.ORISA, Team.ALL, -1, overseerPos, angleToDirection(random.uniform(0, 359.9), 0))
		getLastCreatedEntity().startForcingName("patrol unit or-15")

	hudText(getAllPlayers(), b"\&fullwidth_space; the overseer demands {} {}\&fullwidth_space;".format(resourceIcons[overseerWants], resourceNames[overseerWants]), "", " \n ", HudPosition.TOP, 1, overseerColor, Color.GRAY, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
	hudSubtext(getAllPlayers(), "${} per 10 units sold\&fullwidth_space;|\&fullwidth_space;{}s to next resource".format(exchangeRate * 10, round(phaseTime)), HudPosition.TOP, 1.1, overseerColor, HudReeval.VISIBILITY_AND_STRING)

	### slime rancher
	hudSubtext(localPlayer, " \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n", HudPosition.TOP, 2, Color.GRAY, HudReeval.VISIBILITY)

	progressBarHud(localPlayer, localPlayer.heldContents[localPlayer.resourceSel] / localPlayer.holdCap * 100,
		"{} / {}".format(localPlayer.heldContents[localPlayer.resourceSel], localPlayer.holdCap),
		HudPosition.TOP, 2.2, resourceColors[localPlayer.resourceSel], Color.WHITE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.DEFAULT)
	# createProgressBarInWorldText(localPlayer, localPlayer.heldContents[localPlayer.resourceSel] / localPlayer.holdCap * 100, "{} / {}".format(localPlayer.heldContents[localPlayer.resourceSel], localPlayer.holdCap),
    # updateEveryTick(
    #     localPlayer.getEyePosition() + 100 * (
    #     /* 0 * World Vector Of(Right, Local Player, Rotation) + */
    #     (-1.2 - 0.200) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
    #     3 * localPlayer.getFacingDirection())), 2, Clip.NONE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, resourceColors[localPlayer.resourceSel], Color.WHITE, SpecVisibility.DEFAULT)

rule "player spawn pos?":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	eventPlayer.temp_2 = random.uniform(5.205, 72)
	eventPlayer.temp_2 = 3 + (0.028 * eventPlayer.temp_2 ** 3 + -3.008 * eventPlayer.temp_2 ** 2 + 108 * eventPlayer.temp_2) / 72 + 0.500 * eventPlayer.temp_2
	eventPlayer.temp_1 = spawnCenter + angleToDirection(random.uniform(0, 359.999), 0) * eventPlayer.temp_2
	eventPlayer.temp_2 = raycast(eventPlayer.temp_1, eventPlayer.temp_1 + Vector.DOWN * 10, [], [], false).getHitPosition()
	wait()
	if distance(eventPlayer.temp_1, eventPlayer.temp_2) <= 0.25:
		goto RULE_START
	wait()
	eventPlayer.temp_2 = nearestWalkablePosition(eventPlayer.temp_2)

	# if too close to dealer, engineer, ???, any stash, or any deposit, pick a new spawn
	if distance(eventPlayer.temp_2, marketNPC.getPosition()) <= 6.500 or distance(eventPlayer.temp_2, techNPC.getPosition()) <= 6.500 \
	or distance(eventPlayer.temp_2, vect(7.940, 26.980, 195.610)) <= 120 or distance(eventPlayer.temp_2, vect(86.150, 23.600, 113.380)) <= 120 \
	or any([distance(x, eventPlayer.temp_2) < 8 for x in [p.stashPos for p in getAllPlayers()].exclude(0)]) \
	or any([distance(x, eventPlayer.temp_2) < 5 for x in depositPos.exclude(null)]):
		goto RULE_START

	eventPlayer.stealingMod = 1

rule "player init":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.hasSpawned()

	eventPlayer.stashPos = eventPlayer.temp_2
	eventPlayer.oldStashPos = eventPlayer.stashPos
	eventPlayer.interest = 0.001 * 0.020 * distance(eventPlayer.stashPos, overseerPos) ** 2

	eventPlayer.setPrimaryFireEnabled(false)
	eventPlayer.setSecondaryFireEnabled(false)
	eventPlayer.setAbility1Enabled(false)
	eventPlayer.setAbility2Enabled(false)
	eventPlayer.setUltEnabled(false)

	eventPlayer.disableGamemodeHud()
	# eventPlayer.disableHeroHUD()
	wait()
	techNPC.disableNameplatesFor(getAllPlayers())
	marketNPC.disableNameplatesFor(getAllPlayers())

	eventPlayer.disableRespawn()
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 3)
	eventPlayer.teleport(eventPlayer.stashPos)

	### ui
	# stash
	createIcon(eventPlayer, eventPlayer.stashPos, Icon.TRASHCAN, IconReeval.POSITION, Color.BLUE, true)
	createInWorldText(getAllPlayers(),
		"{}'s stash
		{} {}: {} / {}
		{} {}: {} / {}
		{} {}: {} / {}
		{} {}: {} / {}
		{} {}: {} / {}
		{} {}: {} / {}".format(
			eventPlayer,
			resourceIcons[0], resourceNames[0], floor(eventPlayer.stashContents[0]), eventPlayer.stashCap,
			resourceIcons[1], resourceNames[1], floor(eventPlayer.stashContents[1]), eventPlayer.stashCap,
			resourceIcons[2], resourceNames[2], floor(eventPlayer.stashContents[2]), eventPlayer.stashCap,
			resourceIcons[3], resourceNames[3], floor(eventPlayer.stashContents[3]), eventPlayer.stashCap,
			resourceIcons[4], resourceNames[4], floor(eventPlayer.stashContents[4]), eventPlayer.stashCap,
			resourceIcons[5], resourceNames[5], floor(eventPlayer.stashContents[5]), eventPlayer.stashCap
		), eventPlayer.stashPos + 1.5 * Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	# eventPlayer.stashTxt = getLastCreatedText()

	createEffect(getAllPlayers(), Effect.SPHERE, Color.BLUE, eventPlayer.stashPos + Vector.UP, 2.2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	eventPlayer.activeBeam = BEAMS.OFF

	# take beam
	createBeam(getAllPlayers() if eventPlayer.activeBeam == BEAMS.TAKE else [], Beam.GOOD, BeamOnTarget,
		BeamOnPlayer, resourceColors[eventPlayer.activeBeam], EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

	# put beam, with start & end reversed
	createBeam(getAllPlayers() if eventPlayer.activeBeam == BEAMS.PUT else [], Beam.GOOD, BeamOnPlayer,
		BeamOnTarget, resourceColors[eventPlayer.activeBeam], EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

	bigMessage(eventPlayer, "THE OVERSEER {} {}".format(
		random.choice(["REQUIRES", "NEEDS", "DEMANDS", "CALLS FOR", "LACKS", "WANTS"]),
		resourceNames[overseerWants]
	))

rule "player hero":
	@Event eachPlayer
	@Condition eventPlayer.isAlive()
	eventPlayer.clearStatusEffect(Status.HACKED)
	wait()
	if eventPlayer.getCurrentHero() in [Hero.BAPTISTE, Hero.GENJI, Hero.LUCIO, Hero.HANZO, Hero.MERCY]:
		eventPlayer.setStatusEffect(null, Status.HACKED, 9999)

### npc init
rule "init npcs":
	@Event global
	@Condition techNPC != null
	@Condition marketNPC != null
	moveNPCs()

	wait()
	techNPC.disableRespawn()
	marketNPC.disableRespawn()

	techNPC.setStatusEffect(null, Status.PHASED_OUT, 9999)
	marketNPC.setStatusEffect(null, Status.PHASED_OUT, 9999)

	techNPC.startFacing(directionTowards(techNPC.getEyePosition(), techNPC.npcFaceTarget), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	createInWorldText(getAllPlayers(), "{0} Technician".format(iconString(Icon.BOLT)), techNPC, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)

	marketNPC.startFacing(directionTowards(marketNPC.getEyePosition(), marketNPC.npcFaceTarget), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	createInWorldText(getAllPlayers(), "{0} black market trader".format(abilityIconString(Hero.SOMBRA, Button.ABILITY_1)), marketNPC, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)

rule "npc facing":
	while true:
		techNPC.npcFaceTarget = sorted([x for x in getAllPlayers() if isInLoS(x.getEyePosition(), x.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and not x.isDummy()], lambda y: distance(y, techNPC))[0]
		wait(0.8)
		marketNPC.npcFaceTarget = sorted([x for x in getAllPlayers() if isInLoS(x.getEyePosition(), x.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and not x.isDummy()], lambda y: distance(y, marketNPC))[0]
		wait(0.8)

### player actions
rule "player ded":
	@Event playerDied
	@Condition not eventPlayer.isDummy()
	wait(3.2)
	eventPlayer.respawn()
	eventPlayer.teleport(eventPlayer.oldStashPos)
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 3)

rule "close & personal with the overseer":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition distance(eventPlayer, overseerPos + Vector.DOWN) <= 3
	if eventPlayer.loyalty >= 20:
		smallMessage(eventPlayer, "{} your loyalty has earned you a seat beside me.".format(iconString(Icon.EYE)))
	else:
		kill(eventPlayer, null)
		smallMessage(eventPlayer, "{} ONLY THE TRULY LOYAL MAY APPROACH THE OVERSEER.".format(iconString(Icon.EYE)))

# resources
rule "take":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	@Condition not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
	@Condition eventPlayer.beamCheckCd <= getTotalTimeElapsed()
	@Condition not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	if eventPlayer.carryingStash:
		smallMessage(eventPlayer, "can't use beam while carrying stash.")
	else:

		# retrigger rule with conditions without restating
		eventPlayer.beamCheckCd = getTotalTimeElapsed() + 0.256
		wait(0.24)

### deposits
rule "spawn deposits":
	# if empty, inited or time to despawn
	if depositAmts[i_deposit] <= 0 or depositDespawn[i_deposit] <= getTotalTimeElapsed():
		playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, resourceColors[i_deposit % DepositNo], depositPos[i_deposit], 1)
		# random pos
		Gltemp1 = random.uniform(2, 72)
		Gltemp1 = 3 + ((0.028 * Gltemp1 ** 3 + -3.008 * Gltemp1 ** 2 + 108 * Gltemp1) / 72) + 0.5 * Gltemp1
		Gltemp2 = spawnCenter + angleToDirection(random.uniform(0, 359.999), 0) * Gltemp1
		Gltemp1 = raycast(Gltemp2, Gltemp2 + vect(0, -10, 0), null, null, false).getHitPosition()
		wait()
		if distance(Gltemp2, Gltemp1) <= 0.25:
			goto RULE_START
		Gltemp1 = nearestWalkablePosition(Gltemp1)
		if any([distance(i, Gltemp1) < 8 for i in
			[p.stashPos for p in getAllPlayers()].exclude(0)]):
			goto RULE_START
		wait()
		if any([distance(i, Gltemp1) < 5 for i in depositPos.exclude(null)]):
			goto RULE_START
		if distance(Gltemp2, marketNPC.getPosition()) <= 6.5 or distance(Gltemp2, techNPC.getPosition()) <= 6.5:
			goto RULE_START

		depositAmts[i_deposit] = random.randint(1, 3) * 20 - random.randint(0, 7)
		depositPos[i_deposit] = Gltemp1
		depositDespawn[i_deposit] = getTotalTimeElapsed() + 120

	i_deposit++
	i_deposit %= DepositNo
	wait(0.064)
	goto RULE_START

### bots
rule "init orisas":
	@Event eachPlayer
	@Hero orisa
	@Condition eventPlayer.isDummy()
	@Condition eventPlayer.hasSpawned()
	eventPlayer.disableRespawn()
	eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
	# eventPlayer.disableEnvironmentCollision(false)
	eventPlayer.aiOldPos = vect(45.120, -23.900, 15.140)
	eventPlayer.aiCurrentAngle = horizontalAngleOfDirection(eventPlayer.getFacingDirection())
	eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
	eventPlayer.startThrottleInDirection(eventPlayer.aiMoveDir, 0.5, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)
	# eventPlayer.aiCd = true
	eventPlayer.startFacing(directionTowards(eventPlayer.getEyePosition(), eventPlayer.aiFaceTarget + Vector.UP), 360, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	eventPlayer.aiFaceTarget = eventPlayer + eventPlayer.aiMoveDir

rule "orisa move wip":
	@Event eachPlayer
	@Hero orisa
	@Condition eventPlayer.isDummy()
	# @Condition eventPlayer.aiCd
	@Condition eventPlayer.isAlive()
	do:
		wait(0.256)
		if distance(eventPlayer, vect(159.43, 11.53, 263.44)) <= 2.25:
			playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, overseerColor, eventPlayer.getPosition(), 1)
			eventPlayer.teleport(overseerPos)
			playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, overseerColor, overseerPos, 1)
		# updateFaceTarget
		if entityExists(eventPlayer.aiFaceTarget) and distance(eventPlayer, eventPlayer.aiFaceTarget) > 5:
			eventPlayer.aiMoveDir = directionTowards(eventPlayer, eventPlayer.aiFaceTarget)

		if distance(eventPlayer, eventPlayer.aiOldPos) < 0.1:
			eventPlayer.forceButtonPress(Button.JUMP)
			eventPlayer.aiCurrentAngle = random.randint(0, 359)
			eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)

		eventPlayer.aiOldPos = eventPlayer.getPosition()
		# eventPlayer.AI_cooldown = getTotalTimeElapsed() + 0.25
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += random.randint(20, 40)
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += -60
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += 90
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += -120
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += 150
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += -180
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		if (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 2, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 2, null, null, false).getHitPosition()).y >= eventPlayer.getPosition().y + -2.5 and isInLoS(eventPlayer + Vector.UP, Vector.UP + (raycast(eventPlayer + vect(0, 2.5, 0) + eventPlayer.aiMoveDir * 4, eventPlayer + vect(0, -10, 0) + eventPlayer.aiMoveDir * 4, null, null, false).getHitPosition()), BarrierLos.PASS_THROUGH_BARRIERS):
			continue
		eventPlayer.aiCurrentAngle += -90
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
	while RULE_CONDITION


rule "hi":
	@Event eachPlayer
	@Condition eventPlayer.isDummy()
	@Condition eventPlayer != techNPC # need its variables for npc repos
	while true:
		eventPlayer.temp_2 = getPlayersInRadius(eventPlayer, 6, Team.ALL, LosCheck.SURFACES)
		# if (eventPlayer == techNPC and temp_2)
		if eventPlayer.getCurrentHero() == Hero.ORISA:
			eventPlayer.temp_2 = [x for x in eventPlayer.temp_2 if x.loyalty >= 1]
			if eventPlayer.temp_2:
				eventPlayer.communicate(Comms.HELLO)
				smallMessage(eventPlayer.temp_2, "{}: {}".format(heroIcon(Hero.ORISA), random.choice(orisaQuips)))
		elif eventPlayer == marketNPC:
			eventPlayer.temp_2 = [x for x in eventPlayer.temp_2 if x.loyalty < 0]
			if eventPlayer.temp_2:
				eventPlayer.communicate(Comms.HELLO)
				smallMessage(random.choice(eventPlayer.temp_2), "{} psst... wanna sell some resources?".format(heroIcon(eventPlayer.getCurrentHero())))

		wait(4.8)