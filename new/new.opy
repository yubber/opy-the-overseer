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
# reload - dump (prompt when can't carry stash bc holding stuff)
# interact - npc
# ability 1 - sprint
# ability 2 - next resource
# ult - prev resource
# melee - report

#!extension beamSounds
#!extension playMoreEffects
# idk if need more fx
#!extension spawnMoreDummyBots

/*def moveNPCs():
	while true:
		wait()
		NPCRepos_2 = random.uniform(5.205, 72)
		NPCRepos_2 = 3 + (0.028 * NPCRepos_2 ** 3 + -3.008 * NPCRepos_2 ** 2 + 108 * NPCRepos_2) / 72 + 0.500 * NPCRepos_2
		NPCRepos_1 = spawnCenter + angleToDirection(random.uniform(0,359.99), 0) * NPCRepos_2
		NPCRepos_2 = raycast(NPCRepos_1, NPCRepos_1 + 10 * Vector.DOWN, [], [], false).getHitPosition()
		if distance(NPCRepos_1, NPCRepos_2) <= 0.25:
			continue
		NPCRepos_2 = nearestWalkablePosition(NPCRepos_2)
		wait()
		if distance(NPCRepos_2, vect(7.940, 26.980, 195.610)) <= 120 \
			or distance(NPCRepos_2, vect(86.150, 23.600, 113.380)) <= 120 \
			or any([distance(x.stashPos, NPCRepos_2) < 8 for x in getAllPlayers()].exclude(0)) \
			or any([distance(x, NPCRepos_2) < 5 for x in depositPos.exclude(defaultVect)]):
				# goto RULE_START
				continue
		wait()
		# if tech tped already
		if techNPC.hasStatusEffect(Status.ROOTED):
			if distance(NPCRepos_2, techNPC.getPosition()) < 8:
				continue
			marketNPC.teleport(NPCRepos_2)
			techNPC.clearStatusEffect(Status.ROOTED)
			break
		else:
			techNPC.teleport(NPCRepos_2)
			techNPC.setStatusEffect(null, Status.ROOTED, 10)*/

def updateStats():
	eventPlayer.setMoveSpeed((100 + eventPlayer.upgrades[UPGRADES.MOVE] * 10)  + (eventPlayer.isCarryingStash * -0.3))
	# eventPlayer.setMoveSpeed((100 + eventPlayer.upgrades[2] * 10) * ((1 + ((eventPlayer.sprint_cooldown > getTotalTimeElapsed() + 12.5) * 5)) + eventPlayer.carrying_stash * -0.3))
	eventPlayer.takeRange = 12.5 + eventPlayer.upgrades[UPGRADES.TAKE] * 1.25
	eventPlayer.putRange = 12.5 + eventPlayer.upgrades[UPGRADES.PUT] * 1.25
	eventPlayer.takeSpeed = 0.5 + eventPlayer.upgrades[UPGRADES.TAKE] * 0.1 * 10
	eventPlayer.putSpeed = 0.5 + eventPlayer.upgrades[UPGRADES.PUT] * 0.1 * 10
	eventPlayer.heldCap = 30 + eventPlayer.upgrades[UPGRADES.HOLD] * 3 * 10
	eventPlayer.stashCap = 100 + eventPlayer.upgrades[UPGRADES.STASH] * 10 * 10

rule "global init":
	# disableInspector()
	disableGamemodeCompletion()
	disableScoring()
	setMatchTime(1)
	wait(1.2)
	setMatchTime(4*60+20)
	wait()
	pauseMatchTime()

	hudText(hostPlayer, null,  "peak: {} | average: {}".format(getPeakServerLoad(), getAverageServerLoad()), "server load: {}\n".format(getServerLoad()), HudPosition.RIGHT, -1, Color.ORANGE, Color.GRAY, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)

	patrollerNo = createWorkshopSetting(int[1:9], "difficulty", "number of patrolling orisas", 6, 0)

	### overseer
	overseerColor = random.choice([Color.BLUE, Color.YELLOW])
	createEffect(getAllPlayers(), Effect.CLOUD, overseerColor, overseerPos + Vector.UP, 3, EffectReeval.VISIBILITY)
	createEffect(getAllPlayers(), Effect.GOOD_AURA, overseerColor, overseerPos + Vector.UP, 3 + 0.5 * sinDeg(getTotalTimeElapsed()), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	createIcon(getAllPlayers(), overseerPos + Vector.UP, Icon.EYE, IconReeval.VISIBILITY, overseerColor, false)
	createInWorldText(getAllPlayers(), "THE OVERSEER", overseerPos, 1.75, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	wait()
	### deposits
	for i_init in range(DepositNo):
		depositAmts[i_init] = null
		depositPos[i_init] = null
		depositDespawn[i_init] = 130
		wait()
		createEffect(getAllPlayers(), Effect.ORB, evalOnce(resourceColors[i_init % ResourceNo]), depositPos[evalOnce(i_init % ResourceNo)],
			0.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
		createEffect(getAllPlayers(), Effect.LIGHT_SHAFT, resourceColors[evalOnce(i_init % ResourceNo)], depositPos[evalOnce(i_init % ResourceNo)] + Vector.DOWN * 15,
			0.5 + 0.002 * depositAmts[evalOnce(i_init % ResourceNo)] / 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
		wait()
		# createInWorldText(getAllPlayers(), "{} {}: {}".format(evalOnce(resourceIcons[i_init % ResourceNo]), evalOnce(resourceNames[i_init % ResourceNo]), floor(depositAmts[evalOnce(i_init % ResourceNo)])),
		# 	depositPos[evalOnce(i_init % ResourceNo)] + 1.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
		createInWorldText(getAllPlayers(), "{} {}: {}".format(resourceIcons[evalOnce(i_init % ResourceNo)], resourceNames[evalOnce(i_init % ResourceNo)], floor(depositAmts[evalOnce(i_init % ResourceNo)])),
			depositPos[evalOnce(i_init % ResourceNo)] + 0.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
		wait(0.048)

	### rarities
	i_init = 16
	# 0-5
	rarity = [i_init, i_init, i_init, i_init, i_init, i_init]

	rarityPick[0] = -1
	for i_init in range(1, 7):
		rarityPick[i_init] = 16 * i_init
		wait()

	sellingTech = -1
	createDummy(random.choice([Hero.BRIGITTE, Hero.TORBJORN, Hero.SYMMETRA]), Team.ALL, PlayerSlots, defaultVect, Vector.DOWN)
	techNPC = getLastCreatedEntity()
	techNPC.startForcingName("technician")

	wait()

	createDummy(random.choice([Hero.BAPTISTE, Hero.ANA, Hero.SOMBRA]), Team.ALL, PlayerSlots + 1, defaultVect, Vector.DOWN)
	marketNPC = getLastCreatedEntity()
	marketNPC.startForcingName("black market trader")

	wait()
	### npcs
	# moveNPCs()

	wait()
	# techNPC.disableRespawn()
	# marketNPC.disableRespawn()

	techNPC.setStatusEffect(null, Status.PHASED_OUT, 9999)
	marketNPC.setStatusEffect(null, Status.PHASED_OUT, 9999)
	wait()
	techNPC.startFacing(directionTowards(techNPC.getEyePosition(), techNPC.npcFaceTarget), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	createInWorldText(getAllPlayers(), "{0} Technician".format(iconString(Icon.BOLT)), techNPC, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if distance(localPlayer, techNPC) < 3.5 and isInLoS(localPlayer, techNPC, BarrierLos.PASS_THROUGH_BARRIERS) else [],
		"[{}] - view current offer".format(buttonString(Button.INTERACT)), techNPC + Vector.UP, 1.05, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	wait()
	marketNPC.startFacing(directionTowards(marketNPC.getEyePosition(), marketNPC.npcFaceTarget), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	createInWorldText(getAllPlayers(), "{0} black market trader".format(abilityIconString(Hero.SOMBRA, Button.ABILITY_1)), marketNPC, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if distance(localPlayer, marketNPC) < 3.5 and isInLoS(localPlayer, marketNPC, BarrierLos.PASS_THROUGH_BARRIERS) else [],
		"[{}] - view exchange rates".format(buttonString(Button.INTERACT)), marketNPC + Vector.UP, 1.05, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

	wait()
	for i_init in range(patrollerNo):
		createDummy(Hero.ORISA, Team.ALL, PlayerSlots + 2 + i_init, overseerPos, angleToDirection(random.uniform(0, 359.9), 0))
		getLastCreatedEntity().startForcingName("patrol unit or-15")
		wait()

	### huds
	hudText(getAllPlayers(), b"\&fullwidth_space; the overseer demands {} {}\&fullwidth_space;".format(resourceIcons[overseerWants], resourceNames[overseerWants]), "", " \n ", HudPosition.TOP, 1, overseerColor, Color.GRAY, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
	hudSubtext(getAllPlayers(), "${} per 10 units sold\&fullwidth_space;|\&fullwidth_space;{}s to next resource".format(exchangeRate * 10, round(phaseTime)), HudPosition.TOP, 1.1, overseerColor, HudReeval.VISIBILITY_AND_STRING)

	### slime rancher
	# hudSubtext(localPlayer, " \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n \n ", HudPosition.TOP, 2, Color.GRAY, HudReeval.VISIBILITY)

	# hudSubtext(localPlayer, "[{}] {} \&left_black_triangle; {} {} \&right_black_triangle; {} [{}]".format(
	# 	buttonString(Button.ULTIMATE), (ResourceNo - 1 if localPlayer.resourceSel == 0 else (localPlayer.resourceSel - 1)),
	# 	resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel],
	# 	resourceIcons[(localPlayer.resourceSel + 1) % ResourceNo], buttonString(Button.ABILITY_2)
	# ), HudPosition.TOP, 2.1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING )
	# progressBarHud(localPlayer, localPlayer.heldContents[localPlayer.resourceSel] / localPlayer.heldCap * 100,
	# 	"{} / {}".format(localPlayer.heldContents[localPlayer.resourceSel], localPlayer.heldCap),
	# 	HudPosition.TOP, 2.3, resourceColors[localPlayer.resourceSel], Color.WHITE, ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR, SpecVisibility.DEFAULT)

	createInWorldText(localPlayer, "\&white_square;",
		updateEveryTick(localPlayer.getEyePosition() + 100 * ((-0.75 + localPlayer.resourceSel * 0.2) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
		(-0.5 /*+ 0.03 * sin(2*getTotalTimeElapsed())*/ - 0.200) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
		3 * localPlayer.getFacingDirection())), 4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_COLOR, resourceColors[localPlayer.resourceSel], SpecVisibility.NEVER)

	for i_init in range(ResourceNo):
		# createInWorldText(localPlayer, header, pos, scale, clip, reeval, color, specvis)
		# big icons
		createInWorldText(localPlayer if localPlayer.resourceSel == evalOnce(i_init) else [], resourceIcons[evalOnce(i_init)],
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.6 - 0.2) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 3.6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
		# small icons | -2.5 -1.5 -0.5 0.5 1.5 2.5
		createInWorldText(localPlayer if localPlayer.resourceSel != evalOnce(i_init) else [], resourceIcons[evalOnce(i_init)],
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.6 - 0.2) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 2.4, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
		# held no
		createInWorldText(localPlayer, localPlayer.heldContents[evalOnce(i_init)],
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.8 - 0.2) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 2.2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

	createInWorldText(localPlayer, "[{}] \&left_black_triangle; "SpaceSpam" \&right_black_triangle; [{}]".format(buttonString(Button.ULTIMATE), buttonString(Button.ABILITY_2)),
		updateEveryTick(
		localPlayer.getEyePosition() + 100 * (
		/*(-0.75 + localPlayer.resourceSel * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +*/
		(-0.75 - 0.2) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
		3 * localPlayer.getFacingDirection())), 3, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

	createProgressBarInWorldText(localPlayer,
		localPlayer.heldContents[localPlayer.resourceSel] / localPlayer.heldCap * 100,
		"{} / {}".format(localPlayer.heldContents[localPlayer.resourceSel], localPlayer.heldCap),
		updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			/* 0 * World Vector Of(Right, Local Player, Rotation) + */
			(-1 - 0.200) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 1.6, Clip.NONE, resourceColors[localPlayer.resourceSel], Color.WHITE, ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR, SpecVisibility.DEFAULT)

	# lol. lmao
	# IF ANYONE NEEDS THE SOURCE OVERPY CODE FOR THIS PLESE CONTACT yubber1337@gmail.com I KNOW HOW IT FEELS
	createInWorldText(localPlayer if localPlayer.targetType != TARGETS.NONE else [],
		(
			"can't carry any more" if localPlayer.heldCap <= localPlayer.heldContents[localPlayer.targetIndex % ResourceNo] \
				else ("too far to take" if localPlayer.takeRange < distance(localPlayer, localPlayer.targetPos) else "[{}] - take".format(buttonString(Button.PRIMARY_FIRE)))
		) if localPlayer.targetType == TARGETS.DEPOSIT else (
			"no {} {} to sell".format(resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel]) if localPlayer.heldContents[localPlayer.resourceSel] <= 0 \
			else ("too far to sell" if distance(localPlayer, localPlayer.targetPos) > localPlayer.putRange \
			else "[{}] - sell {} {} (crime)".format(buttonString(Button.SECONDARY_FIRE), resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel]))
		) if localPlayer.targetType == TARGETS.MARKET else (
			"no {} {} to exchange".format(resourceIcons[overseerWants], resourceNames[overseerWants]) if localPlayer.heldContents[overseerWants] <= 0 \
			else ("too far to exchange {} {}".format(resourceIcons[overseerWants], resourceNames[overseerWants]) if distance(localPlayer, localPlayer.targetPos) > localPlayer.putRange \
			else "[{}] - exchange {} {}".format(buttonString(Button.SECONDARY_FIRE), resourceIcons[overseerWants], resourceNames[overseerWants]))
		) if localPlayer.targetType == TARGETS.OVERSEER else (
			"{}\n\n{}".format(
				"too far to take" if distance(localPlayer, localPlayer.targetPos) > localPlayer.takeRange \
				else "stash has no {} {}".format(resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel]) if humanPlayers[localPlayer.targetIndex].stashContents[localPlayer.resourceSel] < 0 \
				else "can't carry any more {} {}".format(resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel]) if localPlayer.heldCap <= localPlayer.heldContents[localPlayer.resourceSel]\
				# button, take/steal, icon, name, crime
				else "[{}] - {} {} {}{}".format(
					buttonString(Button.PRIMARY_FIRE),
					"take" if localPlayer.targetIndex == localPlayer.getSlot() else "steal",
					resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel],
					" (crime)" if localPlayer.targetIndex != localPlayer.getSlot() else ""
				),
				"too far to stash" if distance(localPlayer, localPlayer.targetPos) > localPlayer.putRange \
				else "[{}] - {} {} {}".format(
					buttonString(Button.SECONDARY_FIRE),
					"stash" if humanPlayers[localPlayer.targetIndex] == localPlayer else "donate",
					resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel]
				)
			)
		) if localPlayer.targetType == TARGETS.STASH else "",
		localPlayer.targetPos - Vector.UP, 1.2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT
	) # header, pos, scale, clip, reeval, color, specvis

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

	updateStats()

	### ui
	# stash
	createIcon(eventPlayer, eventPlayer.stashPos + 3*Vector.UP, Icon.TRASHCAN, IconReeval.POSITION, Color.BLUE, true)

	createInWorldText([] if eventPlayer.isCarryingStash else getAllPlayers(), "{}'s stash".format(eventPlayer), eventPlayer.stashPos + 2.5 * Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText([] if eventPlayer.isCarryingStash else getAllPlayers(), "{} {}: {}\n{} {}: {}\n{} {}: {}".format(
		resourceIcons[0], resourceNames[0], eventPlayer.stashContents[0],
		resourceIcons[1], resourceNames[1], eventPlayer.stashContents[1],
		resourceIcons[2], resourceNames[2], eventPlayer.stashContents[2]
		), eventPlayer.stashPos + 0.5 * Vector.UP + worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) * max(2, (-0.1 * distance(localPlayer, eventPlayer.stashPos))),
		1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText([] if eventPlayer.isCarryingStash else getAllPlayers(), "{} {}: {}\n{} {}: {}\n{} {}: {}".format(
		resourceIcons[3], resourceNames[3], eventPlayer.stashContents[3],
		resourceIcons[4], resourceNames[4], eventPlayer.stashContents[4],
		resourceIcons.last(), resourceNames.last(), eventPlayer.stashContents.last()
		), eventPlayer.stashPos + 0.5 * Vector.UP + worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) * max(2, (0.1 * distance(localPlayer, eventPlayer.stashPos))),
		1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)

	createEffect(getAllPlayers(), Effect.SPHERE, Color.BLUE, eventPlayer.stashPos + Vector.UP, 2.2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	eventPlayer.activeBeam = BEAMS.OFF

	# createBeam(getAllPlayers(), Beam.GOOD, eventPlayer,
	# 	eventPlayer.targetPos, Color.VIOLET, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
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
	@Condition not eventPlayer.isDummy()
	eventPlayer.clearStatusEffect(Status.HACKED)
	wait(0.16)
	if eventPlayer.getCurrentHero() in [Hero.BAPTISTE, Hero.GENJI, Hero.LUCIO, Hero.HANZO, Hero.MERCY]:
		eventPlayer.setStatusEffect(null, Status.HACKED, 9999)

### npc
rule "bonk npcs":
	@Disabled
	while true:
		for techNPC.stashPos in range(DepositNo):
			if distance(techNPC, techNPC.stashPos) < 5:
				techNPC.applyImpulse(directionTowards(techNPC.stashPos, techNPC) * vect(1,0,1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
			if distance(marketNPC, techNPC.stashPos) < 5:
				marketNPC.applyImpulse(directionTowards(techNPC.stashPos, marketNPC) * vect(1,0,1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
			wait()

		if distance(techNPC, overseerPos) < 5:
			techNPC.applyImpulse(directionTowards(overseerPos, techNPC) * vect(1,0,1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
		if distance(marketNPC, overseerPos) < 5:
			marketNPC.applyImpulse(directionTowards(overseerPos, marketNPC) * vect(1,0,1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

		# for techNPC.stashPos in range distance(p.stashPos, techNPC) < 8])

		# for techNPC.stashPos in range(len())
		wait(0.08)
rule "npc facing":
	@Disabled
	while true:
		techNPC.aiFaceTarget = sorted([x for x in getAllPlayers() if isInLoS(x.getEyePosition(), x.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and not x.isDummy()], lambda y: distance(y, techNPC))[0]
		wait(0.8)
		marketNPC.aiFaceTarget = sorted([x for x in getAllPlayers() if isInLoS(x.getEyePosition(), x.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and not x.isDummy()], lambda y: distance(y, marketNPC))[0]
		wait(0.8)

### player actions
rule "player/npc ded":
	@Event playerDied
	if eventPlayer.isDummy():
		wait(3)
		if eventPlayer == marketNPC or eventPlayer == techNPC:
			eventPlayer.respawn()
		else:
			eventPlayer.teleport(overseerPos)
			eventPlayer.resurrect()
			playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, overseerColor, overseerPos, 1)
	else:
		wait(3.2)
		eventPlayer.respawn()
		wait()
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

# resources/*
rule "cycle resource prev [q]":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
	do:
		eventPlayer.resourceSel =  ResourceNo - 1 if eventPlayer.resourceSel == 0 else (eventPlayer.resourceSel - 1)
		wait(0.24)
	while RULE_CONDITION

rule "cycle resource next [e]":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
	do:
		eventPlayer.resourceSel = (eventPlayer.resourceSel + 1) % ResourceNo
		wait(0.24)
	while RULE_CONDITION

rule "set targets":
	while true:
		# 0...11 | DepositNo = overseer | marketNPC | players } array of positions
		allTargets = depositPos.concat([overseerPos, marketNPC.getEyePosition()]).concat([p.stashPos for p in getAllPlayers() if not p.isDummy() and not p.isCarryingStash])
		wait(0.096)

rule "get player target":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isAlive()
	do:
		wait(0.096)
		if eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) or eventPlayer.isCarryingStash:
			eventPlayer.beamPrompt = null
			return

		wait(0.08)
		# filters for in range. SET PLAYER RANGE VARS FIRST
		eventPlayer.targets = [x for x in allTargets if isInLoS(eventPlayer.getEyePosition(), x, BarrierLos.PASS_THROUGH_BARRIERS) and distance(eventPlayer, x) <= max(eventPlayer.takeRange, eventPlayer.putRange) and eventPlayer.isInViewAngle(x, 40)]
		wait(0.08)
		if eventPlayer.targets != []:
			eventPlayer.targetPos = sorted(eventPlayer.targets,
				lambda x: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer, x)))[0]
		else:
			eventPlayer.targetType = TARGETS.NONE
			eventPlayer.targetPos = null
			continue

		eventPlayer.targetIndex = allTargets.index(eventPlayer.targetPos)

		# playEffect(eventPlayer, DynamicEffect.BAD_EXPLOSION, Color.PURPLE, eventPlayer.targetPos, 99)

		if eventPlayer.targetIndex == -1:
			smallMessage(hostPlayer, "targeting poopy")
			continue

		if eventPlayer.targetIndex < DepositNo: # deposit
			eventPlayer.targetType = TARGETS.DEPOSIT
		elif eventPlayer.targetIndex == DepositNo: # overseer
			eventPlayer.targetType = TARGETS.OVERSEER
		elif eventPlayer.targetIndex == DepositNo + 1: # marketer
			eventPlayer.targetType = TARGETS.MARKET
		else: # stash
			eventPlayer.targetIndex -= DepositNo + 1
			eventPlayer.targetType = TARGETS.STASH
	while RULE_CONDITION

rule "take":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	@Condition not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
	@Condition not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	@Condition eventPlayer.targetIndex != -1
	do:
		if eventPlayer.isCarryingStash:
			smallMessage(eventPlayer, "can't use beam while carrying stash.")
			return
		else:

		wait(0.24)
	while RULE_CONDITION

### deposits
rule "deposit tp debug":
	@Event eachPlayer
	@Condition hostPlayer.isMeleeing()
	hostPlayer.teleport(depositPos[hostPlayer.aiFaceTarget])
	hostPlayer.aiFaceTarget += 1
	hostPlayer.aiFaceTarget %= DepositNo

rule "spawn deposits":
	# if empty, inited or time to despawn
	while true:
		if depositAmts[i_deposit] <= 0 or depositDespawn[i_deposit] <= getTotalTimeElapsed():
			playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, resourceColors[i_deposit % DepositNo], depositPos[i_deposit], 1)
			# random pos
			Gltemp1 = random.uniform(2, 72)
			Gltemp1 = 3 + ((0.028 * Gltemp1 ** 3 + -3.008 * Gltemp1 ** 2 + 108 * Gltemp1) / 72) + 0.5 * Gltemp1
			Gltemp2 = spawnCenter + angleToDirection(random.uniform(0, 359.999), 0) * Gltemp1
			wait()
			Gltemp1 = raycast(Gltemp2, Gltemp2 + vect(0, -10, 0), null, null, false).getHitPosition()
			if distance(Gltemp2, Gltemp1) <= 0.25:
				goto RULE_START
			wait()
			Gltemp1 = nearestWalkablePosition(Gltemp1) + Vector.UP
			# far from stashes
			if any([distance(i, Gltemp1) < 8 for i in
				[p.stashPos for p in getAllPlayers()].exclude(0)]):
				continue
			wait()
			# far from other deposits
			if any([distance(i, Gltemp1) < 5 for i in depositPos.exclude(null)]):
				continue
			# far from npcs
			wait()
			if distance(Gltemp1, marketNPC.getPosition()) <= 6.5 or distance(Gltemp1, techNPC.getPosition()) <= 6.5:
				continue
			depositAmts[i_deposit] = (random.randint(1, 3) * 20 - random.randint(0, 7)) * 10
			depositPos[i_deposit] = Gltemp1
			depositDespawn[i_deposit] = getTotalTimeElapsed() + 120

		i_deposit++
		i_deposit %= DepositNo
		wait(0.064)

### bots"
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

rule "orisa move":
	@Event eachPlayer
	@Hero orisa
	@Disabled
	@Condition eventPlayer.isDummy()
	# @Condition eventPlayer.aiCd
	@Condition eventPlayer.isAlive()
	do:
		wait(0.24)
		# idfk where this is
		if distance(eventPlayer, vect(159.43, 11.53, 263.44)) <= 2.25:
			playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, overseerColor, eventPlayer.getPosition(), 1)
			eventPlayer.teleport(overseerPos)
			playEffect(getPlayers(Team.1), DynamicEffect.GOOD_PICKUP_EFFECT, overseerColor, overseerPos, 1)

		# update ai facing
		eventPlayer.aiFaceTarget = (sorted([player for player in getLivingPlayers(Team.1) if player.naughty and isInLoS(eventPlayer.getEyePosition(), player + Vector.UP, BarrierLos.PASS_THROUGH_BARRIERS)], lambda i: distance(i, eventPlayer)))
		if eventPlayer.aiFaceTarget == []:
			eventPlayer.aiFaceTarget = eventPlayer + eventPlayer.aiMoveDir * 100
		else:
			eventPlayer.aiFaceTarget = eventPlayer.aiFaceTarget[0]
			if distance(eventPlayer, eventPlayer.aiFaceTarget) > 5:
				eventPlayer.aiMoveDir = directionTowards(eventPlayer, eventPlayer.aiFaceTarget)

		if distance(eventPlayer, eventPlayer.aiOldPos) < 0.1:
			eventPlayer.forceButtonPress(Button.JUMP)
			eventPlayer.aiCurrentAngle = random.randint(0, 359)
			eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)

		eventPlayer.aiOldPos = eventPlayer.getPosition()
		# eventPlayer.AI_cooldown = getTotalTimeElapsed() + 0.25
		orisaRaycastBlackMagic
		wait()
		eventPlayer.aiCurrentAngle += random.randint(20, 40)
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		orisaRaycastBlackMagic
		eventPlayer.aiCurrentAngle += -60
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		orisaRaycastBlackMagic
		wait()
		eventPlayer.aiCurrentAngle += 90
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		orisaRaycastBlackMagic
		eventPlayer.aiCurrentAngle += -120
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		orisaRaycastBlackMagic
		wait()
		eventPlayer.aiCurrentAngle += 150
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		orisaRaycastBlackMagic
		eventPlayer.aiCurrentAngle += -180
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
		orisaRaycastBlackMagic
		wait()
		eventPlayer.aiCurrentAngle += -90
		eventPlayer.aiMoveDir = angleToDirection(eventPlayer.aiCurrentAngle, 0)
	while RULE_CONDITION

rule "orisa hi":
	@Event eachPlayer
	@Disabled
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