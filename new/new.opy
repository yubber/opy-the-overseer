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
				#"workshopChamber"
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
			"lifeweaver": {
                "enableAbility2": false,
                "enableSecondaryFire": false,
                "enablePrimaryFire": false,
                "enableAbility1": false,
                "enableUlt": false,
                "weaponsEnabled": "healingBlossom"
            },
            "general": {
                # "enableMelee": false,
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

#!define fixdp(x)	"{}.{}0".format(floor(x), floor(((x) * 10) % 10))

# bindings
# crouch - stash pickup
# reload - dump (prompt when can't carry stash bc holding stuff)
# interact - npc
# ability 1 - sprint
# ability 2 - next resource
# ult - prev resource
# melee - report

/*todo
- fix bonking
- interest payment (in bursts)
- remote stash content view
- change overseer color to gray/black/white for Appropriateness
to check
- debug move stash
- check bug: quickly swapping to put beam allows putting in a deposit
- check remove tooltip when stash picked up
to fix
- resource bar qol (pips 0 only when empty, pips max only when max)
- bonking
- stash tooltip flicker
- stash content hud spacing
- new heroes weapon pos
- technician dialog init
ideas
- what if deposits were monsters to fight (like polish salt mine)*/

#!extension beamSounds
#!extension playMoreEffects
# idk if need more fx
#!extension spawnMoreDummyBots

def executeBonk(): # technpc old stash pos is player, stashpos is source
	techNPC.oldStashPos.applyImpulse(directionTowards(techNPC.stashPos, techNPC.oldStashPos) * vect(1,0.2,1), 10, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)

def cleanBeam():
	eventPlayer.beamTarget = null
	eventPlayer.beamTargetIndex = -1
	eventPlayer.beamTargetType = TARGETS.NONE
	eventPlayer.naughty = false
	eventPlayer.beamType = BEAMS.OFF

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
	eventPlayer.takeSpeed = 0.5 + eventPlayer.upgrades[UPGRADES.TAKE] * 0.1 * ResourceScalar
	eventPlayer.putSpeed = 0.5 + eventPlayer.upgrades[UPGRADES.PUT] * 0.1 * ResourceScalar
	eventPlayer.heldCap = 30 + eventPlayer.upgrades[UPGRADES.HOLD] * 3 * ResourceScalar
	eventPlayer.stashCap = 100 + eventPlayer.upgrades[UPGRADES.STASH] * 10 * ResourceScalar

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
	overseerColor = random.choice([Color.BLUE, Color.GRAY, Color.RED])
	createEffect(getAllPlayers(), Effect.CLOUD, overseerColor, overseerPos + Vector.UP, 3, EffectReeval.VISIBILITY)
	createEffect(getAllPlayers(), Effect.SPHERE, overseerColor, overseerPos + Vector.UP, 3 + 0.5 * sin(getTotalTimeElapsed()), EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	createIcon(getAllPlayers(), overseerPos + Vector.UP, Icon.EYE, IconReeval.VISIBILITY, overseerColor, false)
	createInWorldText(getAllPlayers(), "THE OVERSEER", overseerPos, 1.75, Clip.SURFACES, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	wait()
	### deposits
	for i_init in range(DepositNo):
		depositAmts[i_init] = null
		depositPos[i_init] = null
		depositDespawn[i_init] = 130
		wait()
		createEffect(localPlayer, Effect.ORB, resourceColors[i_init % ResourceNo],
			depositPos[evalOnce(i_init)],
			0.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
		createEffect(localPlayer, Effect.LIGHT_SHAFT, resourceColors[evalOnce(i_init % ResourceNo)], depositPos[evalOnce(i_init)] + Vector.DOWN * 15,
			0.5 + 0.002 * depositAmts[evalOnce(i_init)] / 10, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
		wait()
		# createInWorldText(localPlayer, "{} {}: {}".format(evalOnce(resourceIcons[i_init % ResourceNo]), evalOnce(resourceNames[i_init % ResourceNo]), floor(depositAmts[evalOnce(i_init)])),
		# 	depositPos[evalOnce(i_init)] + 1.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer, "{} {}: {}".format(resourceIcons[evalOnce(i_init % ResourceNo)], resourceNames[evalOnce(i_init % ResourceNo)], floor(depositAmts[evalOnce(i_init)])),
			depositPos[evalOnce(i_init)] + 0.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
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

	techNPC.setStatusEffect(null, Status.UNKILLABLE, 9999)
	marketNPC.setStatusEffect(null, Status.UNKILLABLE, 9999)
	wait()
	techNPC.startFacing(directionTowards(techNPC.getEyePosition(), techNPC.npcFaceTarget), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	createInWorldText(getAllPlayers(), "{0} Technician".format(iconString(Icon.BOLT)), techNPC, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if distance(localPlayer, techNPC) < 3.5 and isInLoS(localPlayer, techNPC, BarrierLos.PASS_THROUGH_BARRIERS) else [],
		"{} {}.
		[{}] - accept".format(
			heroIcon(techNPC.getCurrentHero()),
			"i don't have anything you could use at the moment." if localPlayer.upgrades[sellingTech] >= 10 \
			else "{} Ø{}".format([
				"i can offer you a better harvesting beam for",
				"how about an upgrade to your dispenser beam? it's just",
				"i'll install some faster robotic legs on you if you give me",
				"i can expand your mobile storage capacity for only",
				"i can increase your stash size. only",
				"this sweet camo tech will help you hide from orisas. it's yours for"
			][sellingTech], round(localPlayer.upgrades[sellingTech] + 2.5 * (localPlayer.upgrades[sellingTech] ** 2))),
			buttonString(Button.INTERACT)
		), techNPC + Vector.UP, 1.2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	wait()
	marketNPC.startFacing(directionTowards(marketNPC.getEyePosition(), marketNPC.npcFaceTarget), 100, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	createInWorldText(getAllPlayers(), "{0} black market trader".format(abilityIconString(Hero.SOMBRA, Button.ABILITY_1)), marketNPC, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if distance(localPlayer, marketNPC) < 3.5 and isInLoS(localPlayer, marketNPC, BarrierLos.PASS_THROUGH_BARRIERS) else [],
		"[{}] - view exchange rates".format(buttonString(Button.INTERACT)), marketNPC + Vector.UP, 1.05, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

	wait()
	# give birth to orisas
	for i_init in range(patrollerNo):
		createDummy(Hero.ORISA, Team.ALL, PlayerSlots + 2 + i_init, overseerPos, angleToDirection(random.uniform(0, 359.9), 0))
		getLastCreatedEntity().startForcingName("patrol unit or-{}".format(15 + i_init))
		wait()

	### huds
	hudText(getAllPlayers(), b"\&fullwidth_space; the overseer demands {} {}\&fullwidth_space;".format(resourceIcons[overseerWants], resourceNames[overseerWants]), "", " \n ", HudPosition.TOP, 1, overseerColor, Color.GRAY, Color.GRAY, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.ALWAYS)
	hudSubtext(getAllPlayers(), "Ø{} per 10 units sold\&fullwidth_space;|\&fullwidth_space;{}s to next resource".format(exchangeRate * 10, round(phaseTime)), HudPosition.TOP, 1.1, overseerColor, HudReeval.VISIBILITY_AND_STRING)

	hudSubtext(getAllPlayers(), " \n \n \n ", HudPosition.TOP, 3, Color.GRAY, HudReeval.VISIBILITY)
	hudHeader([x for x in getAllPlayers() if x.naughty], b"{} committing crime".format(iconString(Icon.WARNING)), HudPosition.TOP, 3.1, Color.ORANGE, HudReeval.VISIBILITY)
	hudSubtext([x for x in getAllPlayers() if x.naughty], "orisas and other players can report you.", HudPosition.TOP, 3.2, Color.ORANGE, HudReeval.VISIBILITY)
	progressBarHud([x for x in getAllPlayers() if x.dumpProg > 0], localPlayer.dumpProg, "[{}] - deleting held resources".format(buttonString(Button.RELOAD)), HudPosition.TOP, 7, Color.RED, Color.RED, ProgressHudReeval.VISIBILITY_AND_VALUES, SpecVisibility.DEFAULT)

	hudText(getAllPlayers(), "Ø", l"Money", "{} overbles".format(localPlayer.money), HudPosition.LEFT, 1, Color.GREEN, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)
	hudText(getAllPlayers(), iconString(Icon.EYE), "loyalty", "{} points".format(localPlayer.loyaltyRank), HudPosition.LEFT, 2, Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

	hudSubtext(getAllPlayers(), " \n[{}] - view stash contents\n(only updates when looking at your stash)".format(buttonString(Button.CROUCH)), HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.NEVER)

	### slime rancher
	# crosshair
	createInWorldText(getLivingPlayers(Team.ALL), "\&white_circle;",
		updateEveryTick(localPlayer.getEyePosition() + localPlayer.getFacingDirection() * 999), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.LIME_GREEN, SpecVisibility.NEVER)

	createInWorldText(getLivingPlayers(Team.ALL), "\&down_black_triangle;",
		updateEveryTick(localPlayer.getEyePosition() + 100 * ((-0.75 + localPlayer.resourceSel * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
		(-0.35 + 0.03 * sin(2*getTotalTimeElapsed()) - 0.200 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
		3 * localPlayer.getFacingDirection())), 2.4, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_COLOR, resourceColors[localPlayer.resourceSel], SpecVisibility.NEVER)

	# ui
	for i_init in range(ResourceNo):
		# createInWorldText(localPlayer, header, pos, scale, clip, reeval, color, specvis)
		# big icons
		createInWorldText(localPlayer if localPlayer.resourceSel == evalOnce(i_init) and localPlayer.isAlive() else [], resourceIcons[evalOnce(i_init)],
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.6 - 0.2 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 3.6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
		# small icons | -2.5 -1.5 -0.5 0.5 1.5 2.5
		createInWorldText(localPlayer if localPlayer.resourceSel != evalOnce(i_init) and localPlayer.isAlive()else [], resourceIcons[evalOnce(i_init)],
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.6 - 0.2 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 2.4, Clip.NONE, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.NEVER)
		# held no
		createInWorldText(getLivingPlayers(Team.ALL), fixdp(localPlayer.heldContents[evalOnce(i_init)]),
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.8 - 0.2 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 1.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)
		# held bars
		createInWorldText(getLivingPlayers(Team.ALL),
			" {}{} ".format(
				"■■■■■".substring(0, (floor(localPlayer.heldContents[evalOnce(i_init)] / localPlayer.heldCap * 5))),
				"□□□□□".substring(0, (ceil(5 - (localPlayer.heldContents[evalOnce(i_init)] / localPlayer.heldCap * 5))))
				),# "■" if localPlayer.heldContents[evalOnce(i_init)] >= localPlayer.heldCap else "□"),
			updateEveryTick(
			localPlayer.getEyePosition() + 100 * (
			evalOnce(-0.75 + i_init * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +
			(-0.9 - 0.2 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
			3 * localPlayer.getFacingDirection())), 0.9, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, resourceColors[evalOnce(i_init)], SpecVisibility.NEVER)

	# button prompts
	createInWorldText(getLivingPlayers(Team.ALL), "[{}] \&left_black_triangle; "SpaceSpam" \&right_black_triangle; [{}]".format(buttonString(Button.ULTIMATE), buttonString(Button.ABILITY_2)),
		updateEveryTick(
		localPlayer.getEyePosition() + 100 * (
		/*(-0.75 + localPlayer.resourceSel * 0.3) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +*/
		(-0.6 - 0.2 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
		3 * localPlayer.getFacingDirection())), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

	# todo change to held & stash 1, max 1 iwt
	createInWorldText(getLivingPlayers(Team.ALL),
		"stashed"SpaceSpam SpaceLite"max {}".format(localPlayer.stashCap) if localPlayer.isHoldingButton(Button.CROUCH) \
		else "\&fullwidth_space;held"SpaceSpam SpaceLite"max {}".format(localPlayer.heldCap),
		updateEveryTick(
		localPlayer.getEyePosition() + 100 * (
		/*(-0.1) * worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) +*/
		(-0.87 - 0.2 + HudOffset) * angleToDirection(horizontalAngleOfDirection(localPlayer.getFacingDirection()), verticalAngleOfDirection(localPlayer.getFacingDirection()) - 90) +
		3 * localPlayer.getFacingDirection())), 2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER)

	# lol. lmao
	# IF ANYONE NEEDS THE SOURCE OVERPY CODE FOR THIS PLESE CONTACT yubber0@proton.me I KNOW HOW IT FEELS
	createInWorldText(localPlayer if localPlayer.targetType != TARGETS.NONE else [],
		(
			"can't carry any more" if localPlayer.heldCap <= localPlayer.heldContents[localPlayer.targetIndex % ResourceNo] \
				else ("too far to take" if localPlayer.takeRange < distance(localPlayer, localPlayer.targetPos) else "[{}] - collect".format(buttonString(Button.PRIMARY_FIRE)))
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
					"stash" if localPlayer.targetIndex == localPlayer.getSlot() else "donate",
					resourceIcons[localPlayer.resourceSel], resourceNames[localPlayer.resourceSel]
				)
			)
		) if localPlayer.targetType == TARGETS.STASH else "",
		localPlayer.targetPos - Vector.UP * (2 if localPlayer.targetType == TARGETS.STASH else 1), 1.2, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.NEVER
	) # header, pos, scale, clip, reeval, color, specvis

	print("targ type {}".format(["depo", "overs", "stash", "market"][hostPlayer.beamTargetType]))
	print("beam type {}".format(["take", "put"][hostPlayer.beamType]))
	print("index {}".format(hostPlayer.beamTargetIndex))
	print(getPlayersInSlot(hostPlayer.beamTargetIndex, Team.ALL))

	phaseTime = 1

rule "player spawn pos?":
	@Event eachPlayer
	@Condition (not eventPlayer.isDummy()) or eventPlayer.getSlot() < PlayerSlots
	eventPlayer.temp_2 = random.uniform(5.205, 72)
	eventPlayer.temp_2 = 3 + (0.028 * eventPlayer.temp_2 ** 3 + -3.008 * eventPlayer.temp_2 ** 2 + 108 * eventPlayer.temp_2) / 72 + 0.500 * eventPlayer.temp_2
	eventPlayer.temp_1 = spawnCenter + angleToDirection(random.uniform(0, 359.999), 0) * eventPlayer.temp_2
	eventPlayer.temp_2 = raycast(eventPlayer.temp_1, eventPlayer.temp_1 + Vector.DOWN * 10, [], [], false).getHitPosition()
	wait()
	if distance(eventPlayer.temp_1, eventPlayer.temp_2) <= 0.25:
		goto RULE_START
	wait()
	eventPlayer.temp_2 = nearestWalkablePosition(eventPlayer.temp_2) + Vector.UP

	# if too close to dealer, engineer, ???, any stash, or any deposit, pick a new spawn
	if distance(eventPlayer.temp_2, marketNPC.getPosition()) <= 6.500 or distance(eventPlayer.temp_2, techNPC.getPosition()) <= 6.500 \
	or distance(eventPlayer.temp_2, vect(7.940, 26.980, 195.610)) <= 120 or distance(eventPlayer.temp_2, vect(86.150, 23.600, 113.380)) <= 120 \
	or any([distance(x, eventPlayer.temp_2) < 8 for x in [p.stashPos for p in getAllPlayers()].exclude(0)]) \
	or any([distance(x, eventPlayer.temp_2) < 5 for x in depositPos.exclude(null)]):
		goto RULE_START

	eventPlayer.naughtyMult = 1

	eventPlayer.setAllowedHeroes(getAllHeroes())

rule "player init":
	@Event eachPlayer
	@Condition (not eventPlayer.isDummy()) or eventPlayer.getSlot() < PlayerSlots
	@Condition eventPlayer.hasSpawned()

	eventPlayer.stashPos = eventPlayer.temp_2
	eventPlayer.oldStashPos = eventPlayer.stashPos
	eventPlayer.interest = InterestFormula

	eventPlayer.targetIndex = -1
	eventPlayer.beamTargetType = TARGETS.NONE

	eventPlayer.setPrimaryFireEnabled(false)
	eventPlayer.setSecondaryFireEnabled(false)
	eventPlayer.setAbility1Enabled(false)
	eventPlayer.setAbility2Enabled(false)
	eventPlayer.setUltEnabled(false)
	eventPlayer.setDamageDealt(0)

	eventPlayer.disableGamemodeHud()
	eventPlayer.disableHeroHUD()
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

	createInWorldText([] if eventPlayer.isCarryingStash else getAllPlayers(), "{}'s stash\n{} max per resource".format(eventPlayer, eventPlayer.stashCap), eventPlayer.stashPos + 2.5 * Vector.UP, 1.5, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText([] if eventPlayer.isCarryingStash else getAllPlayers(), "{} {}: {}\n{} {}: {}\n{} {}: {}".format(
		resourceIcons[0], resourceNames[0], fixdp(eventPlayer.stashContents[0]),
		resourceIcons[1], resourceNames[1], fixdp(eventPlayer.stashContents[1]),
		resourceIcons[2], resourceNames[2], fixdp(eventPlayer.stashContents[2])
		), eventPlayer.stashPos + 0 * Vector.UP + worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) * min(-0.82, (-0.15 * distance(localPlayer, eventPlayer.stashPos))), # min(-0.6, (-0.15 * distance(localPlayer, eventPlayer.stashPos)))
		1.4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

	createInWorldText([] if eventPlayer.isCarryingStash else getAllPlayers(), "{} {}: {}\n{} {}: {}\n{} {}: {}".format(
		resourceIcons[3], resourceNames[3], fixdp(eventPlayer.stashContents[3]),
		resourceIcons[4], resourceNames[4], fixdp(eventPlayer.stashContents[4]),
		resourceIcons.last(), resourceNames.last(), fixdp(eventPlayer.stashContents.last())
		), eventPlayer.stashPos + 0 * Vector.UP + worldVector(Vector.RIGHT, localPlayer, Transform.ROTATION) * max(0.82, (0.15 * distance(localPlayer, eventPlayer.stashPos))),
		1.4, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

	createEffect(getAllPlayers(), Effect.SPHERE, Color.BLUE if localPlayer == eventPlayer else Color.SKY_BLUE, eventPlayer.stashPos, 2.2, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

	eventPlayer.beamType = BEAMS.OFF

	# createBeam(getAllPlayers(), Beam.GOOD, eventPlayer,
	# 	eventPlayer.targetPos, Color.VIOLET, EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
	# take beam
	createBeam(getAllPlayers() if eventPlayer.beamType == BEAMS.TAKE else [], Beam.GOOD, BeamOnTarget,
		BeamOnPlayer, resourceColors[eventPlayer.resourceSel], EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
	createEffect(getAllPlayers() if eventPlayer.beamType == BEAMS.TAKE else [], Effect.ORISA_HALT_TENDRIL_SOUND, Color.WHITE, eventPlayer, 60, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	# put beam, with start & end reversed
	createEffect(getAllPlayers() if eventPlayer.beamType == BEAMS.PUT else [], Effect.SYMMETRA_PROJECTOR_SOUND, Color.WHITE, eventPlayer, 70, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createBeam(getAllPlayers() if eventPlayer.beamType == BEAMS.PUT else [], Beam.GOOD, BeamOnPlayer,
		BeamOnTarget, resourceColors[eventPlayer.resourceSel], EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)

	bigMessage(eventPlayer, "THE OVERSEER {} {}".format(
		random.choice(["REQUIRES", "NEEDS", "DEMANDS", "CALLS FOR", "LACKS", "WANTS"]),
		resourceNames[overseerWants]
	))

	waitUntil(eventPlayer.getThrottle() != vect(0,0,0), 69)
	wait(2)
	smallMessage(eventPlayer, "{} bring the overseer what he asks for.".format(iconString(Icon.EYE)))
	wait(3)
	smallMessage(eventPlayer, "{} it is our duty as good citizens.".format(iconString(Icon.EYE)))
	wait(3)
	smallMessage(eventPlayer, "{} fulfil it and you will be rewarded generously.".format(iconString(Icon.EYE)))

rule "player hero":
	@Event eachPlayer
	@Condition eventPlayer.isAlive()
	@Condition not eventPlayer.isDummy()
	eventPlayer.clearStatusEffect(Status.HACKED)
	wait(0.16)
	if eventPlayer.getCurrentHero() in [Hero.BAPTISTE, Hero.KIRIKO, Hero.GENJI, Hero.LUCIO, Hero.HANZO, Hero.MERCY]:
		eventPlayer.setStatusEffect(null, Status.HACKED, 9999)

	eventPlayer.weaponX = {
		Hero.REAPER: [0.33, 0.18],
		Hero.TRACER: [0.35, 0.14],
		Hero.MERCY: [0.08, 0.12],
		Hero.HANZO: [0.03, 0.41],
		Hero.TORBJORN: [0.1,0.06],
		Hero.REINHARDT: [0.42, 0.09],
		Hero.PHARAH: [0.11, 0.16],
		Hero.WINSTON: [0.2, 0.35],
		Hero.WIDOWMAKER: [0.13, 0.16],
		Hero.BASTION: [0.21, 0.15],
		Hero.SYMMETRA: [0.28, 0.19],
		Hero.ZENYATTA: [0, 0.4],
		Hero.GENJI: [-0.44, 0.42],
		Hero.ROADHOG: [0.26, 0.15],
		Hero.MCCREE: [0.15, 0.07],
		Hero.JUNKRAT: [0.19, 0.15],
		Hero.ZARYA: [0.24, 0.22],
		Hero.SOLDIER: [0.15, 0.14],
		Hero.LUCIO: [0.3, 0.23],
		Hero.MEI: [0.24, 0.13],
		Hero.SOMBRA: [0.29, 0.13],
		Hero.DOOMFIST: [-0.57, 0.32],
		Hero.ANA: [0.12, 0.09],
		Hero.ORISA: [0.33, 0.19],
		Hero.BRIGITTE: [0.92, -0.11],
		Hero.MOIRA: [0.79, 0.38],
		Hero.HAMMOND: [0.65, 0.33],
		Hero.ASHE: [0.15, 0.07],
		Hero.ECHO: [0.78, 0.46],
		Hero.BAPTISTE: [0.19, 0.11],
		Hero.SIGMA: [0.38, 0.13],
		Hero.SOJOURN: [0.15, 0.13],
		Hero.KIRIKO: [-0.53, 0.08],
		Hero.JUNKER_QUEEN: [0.22, 0.13],
		Hero.LIFEWEAVER: [0.68, 0.25],
		Hero.RAMATTRA: [0.58, -0.32],
    	Hero.ILLARI: [0.18, 0.21]
	}[eventPlayer.getCurrentHero()]

	eventPlayer.weaponY = eventPlayer.weaponX.last()
	eventPlayer.weaponX = eventPlayer.weaponX[0]

	if eventPlayer.getCurrentHero() in [Hero.TRACER, Hero.GENJI]:
		eventPlayer.setMoveSpeed(100)
	else:
		eventPlayer.setMoveSpeed((6/5.5)*100)

	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)

	if eventPlayer == hostPlayer:
		eventPlayer.setMoveSpeed(250)

### game flow
rule "phase timer":
	@Condition phaseTime > 0
	phaseTime--
	wait(1)
	if phaseTime <= 0:
		if wantQueue == []:
			wantQueue = random.shuffle(no0to7.slice(0, 6))

		overseerWants = wantQueue[0]
		wantQueue = wantQueue.slice(1, 69)

		playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.TURQUOISE, techNPC, 1)
		playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.VIOLET, marketNPC, 1)
		techNPC.respawn()
		marketNPC.respawn()

		sellingTech = random.choice(no0to7.slice(0,6).exclude(sellingTech))

		phaseTime = random.randint(150, 200)
	goto RULE_START

rule "update loyalty":
	@Event eachPlayer
	@Condition eventPlayer.isAlive()
	do:
		wait(2.4)
		eventPlayer.loyaltyRank = round(eventPlayer.loyaltyPoints * (-0.008 * 0.04 * 0.04 * abs(eventPlayer.loyaltyPoints) + 0.8 * 0.04))
		if eventPlayer.loyaltyRank > 1250:
			eventPlayer.loyaltyRank = 20 + (eventPlayer.loyaltyPoints < 0) * -40
		eventPlayer.naughtyMult = 1 + ((eventPlayer.loyaltyRank >= 1) * (eventPlayer.loyaltyRank + -0.5))
	while RULE_CONDITION

### npc
rule "bonk npcs":
	while true:
		# deposits
		for techNPC.isCarryingStash in range(DepositNo):
			techNPC.stashPos = depositPos[techNPC.isCarryingStash]
			if distance(techNPC, techNPC.stashPos) < 5:
				techNPC.oldStashPos = techNPC
				executeBonk()
			if distance(marketNPC, techNPC.stashPos) < 5:
				techNPC.oldStashPos = marketNPC
				executeBonk()
			wait()

		# overseer
		techNPC.stashPos = overseerPos
		if distance(techNPC, overseerPos) < 5:
			techNPC.oldStashPos = techNPC
			executeBonk()
		if distance(marketNPC, overseerPos) < 5:
			techNPC.oldStashPos = marketNPC
			executeBonk()

		# stashes
		for techNPC.isCarryingStash in range(PlayerSlots):
			techNPC.stashPos = getPlayersInSlot(techNPC.isCarryingStash, Team.ALL).stashPos
			if distance(techNPC, techNPC.stashPos) < 4:
				techNPC.oldStashPos = techNPC
				executeBonk()
			if distance(marketNPC, techNPC.stashPos) < 5:
				techNPC.oldStashPos = marketNPC
				executeBonk()

		wait(0.24)
rule "npc facing":
	while true:
		techNPC.aiFaceTarget = sorted([x for x in getAllPlayers() if isInLoS(x.getEyePosition(), x.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and not x.isDummy()], lambda y: distance(y, techNPC))[0]
		wait(0.8)
		marketNPC.aiFaceTarget = sorted([x for x in getAllPlayers() if isInLoS(x.getEyePosition(), x.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) and not x.isDummy()], lambda y: distance(y, marketNPC))[0]
		wait(0.8)

### player actions
rule "move stash":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.CROUCH)
	@Condition eventPlayer.beamType == BEAMS.OFF
	@Condition distance(eventPlayer, eventPlayer.stashPos) < 2.4
	@Condition isInLoS(eventPlayer.getEyePosition(), eventPlayer.stashPos, BarrierLos.PASS_THROUGH_BARRIERS)
	if eventPlayer.heldContents != [0 for x in resourceNames]:
		smallMessage(eventPlayer, "you can't carry your stash with resources in your inventory.")
		return

	if eventPlayer.isCarryingStash:
		if distance(eventPlayer, techNPC) < 6.5 or distance(eventPlayer, marketNPC) < 6.5:
			smallMessage(eventPlayer, "your stash can't be too close to an NPC.")
		elif distance(eventPlayer, overseerPos) <= 12.333:
			smallMessage(eventPlayer, "{} move your stash farther from the overseer, peasant.".format(iconString(Icon.EYE)))
		elif any([distance(eventPlayer, x) < 5 for x in depositPos]):
			smallMessage(eventPlayer, "your stash can't be too close to a resource deposit.")
		# if player exists and is not event player
		elif any([distance(eventPlayer, getPlayersInSlot(x, Team.ALL).stashPos) < 8 for x in no0to7 if (getPlayersInSlot(x, Team.ALL).stashPos != null) and eventPlayer.getSlot() != x]):
			smallMessage(eventPlayer, "your stash can't be too close to others' stashes.")
		else:
			goto lbl_0
		return
		lbl_0:
		eventPlayer.stashPos = eventPlayer.getPosition() + Vector.UP
		eventPlayer.interest = InterestFormula
		playEffect(getAllPlayers(), DynamicEffect.RING_EXPLOSION, Color.SKY_BLUE, eventPlayer, 3.5)
		wait()
		eventPlayer.oldStashPos = eventPlayer.stashPos
		eventPlayer.isCarryingStash = false
	else:
		eventPlayer.stashPos = null
		eventPlayer.isCarryingStash = true
		eventPlayer.targetPos = null
		eventPlayer.targetType = TARGETS.NONE
	updateStats()

rule "stash contents hud":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition eventPlayer.isAlive()
	do:
		if eventPlayer.isInViewAngle(eventPlayer.stashPos, 70) and isInLoS(eventPlayer.stashPos, eventPlayer.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS):
			eventPlayer.lastStashUpdate = getTotalTimeElapsed()
			eventPlayer.oldStashContents = eventPlayer.stashContents
		wait(0.64)
	while RULE_CONDITION

rule "player/npc ded":
	@Event playerDied
	if eventPlayer.isDummy():
		wait(3)
		if eventPlayer == marketNPC or eventPlayer == techNPC:
			eventPlayer.respawn()
		else:
			eventPlayer.teleport(overseerPos)
			wait()
			eventPlayer.resurrect()
			playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, overseerColor, overseerPos, 1)
	else:
		eventPlayer.naughty = false
		cleanBeam()
		wait(3.2)
		eventPlayer.respawn()
		wait()
		eventPlayer.teleport(eventPlayer.oldStashPos)
		eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 3)

rule "close & personal with the overseer":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition distance(eventPlayer, overseerPos + Vector.DOWN) <= 3
	if eventPlayer.loyaltyRank >= 20:
		smallMessage(eventPlayer, "{} your loyalty has earned you a seat beside me.".format(iconString(Icon.EYE)))
	else:
		kill(eventPlayer, null)
		smallMessage(eventPlayer, "{} ONLY THE TRULY LOYAL MAY APPROACH THE OVERSEER.".format(iconString(Icon.EYE)))

# resources
rule "delete resources":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.RELOAD)
	wait(0.096)
	eventPlayer.dumpProg += 4
	if eventPlayer.dumpProg >= 100:
		eventPlayer.dumpProg = 0
		eventPlayer.heldContents = [0 for x in resourceNames]
		return
		# eventPlayer.heldContents[eventPlayer.resourceSel] = 0
	if eventPlayer.isHoldingButton(Button.RELOAD):
		goto RULE_START
	else:
		eventPlayer.dumpProg = 0

rule "cycle resource prev [q]":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
	# @Condition eventPlayer.beamTargetType != TARGETS.STASH
	@Condition eventPlayer.beamTargetType != TARGETS.DEPOSIT
	@Condition eventPlayer.beamTargetType != TARGETS.OVERSEER
	do:
		eventPlayer.resourceSel =  ResourceNo - 1 if eventPlayer.resourceSel == 0 else (eventPlayer.resourceSel - 1)
		wait(0.24, Wait.ABORT_WHEN_FALSE)
	while RULE_CONDITION

rule "cycle resource next [e]":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
	# @Condition eventPlayer.beamTargetType != TARGETS.STASH
	@Condition eventPlayer.beamTargetType != TARGETS.DEPOSIT
	@Condition eventPlayer.beamTargetType != TARGETS.OVERSEER
	do:
		eventPlayer.resourceSel = (eventPlayer.resourceSel + 1) % ResourceNo
		wait(0.24, Wait.ABORT_WHEN_FALSE)
	while RULE_CONDITION

rule "set targets":
	while true:
		# resource deposits 0...11 | DepositNo = overseer | marketNPC | players } array of positions
		allTargets = depositPos.concat([overseerPos, marketNPC.getEyePosition()]).concat(
			[getPlayersInSlot(p, Team.ALL).stashPos for p in no0to7 if not getPlayersInSlot(p, Team.ALL).isCarryingStash])
		wait(0.096)

rule "get player target":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isAlive()
	@Condition not eventPlayer.isCarryingStash
	@Condition not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	do:
		wait(0.096)
		# filters for in range. SET PLAYER RANGE VARS FIRST
		eventPlayer.targets = [x for x in allTargets if x != null and isInLoS(eventPlayer.getEyePosition(), x, BarrierLos.PASS_THROUGH_BARRIERS) and distance(eventPlayer, x) <= max(eventPlayer.takeRange, eventPlayer.putRange) and eventPlayer.isInViewAngle(x, 40)]
		wait()
		if eventPlayer.targets != []:
			eventPlayer.targetPos = sorted(eventPlayer.targets,
				lambda x: angleBetweenVectors(eventPlayer.getFacingDirection(), directionTowards(eventPlayer, x)))[0]
		else:
			eventPlayer.targetType = TARGETS.NONE
			eventPlayer.targetIndex = TARGETS.NONE
			eventPlayer.targetPos = null
			continue

		wait()
		# moved up to thwart stash hud flicker issues
		if allTargets.index(eventPlayer.targetPos) > DepositNo + 1:
			eventPlayer.targetIndex = allTargets.index(eventPlayer.targetPos) - (DepositNo + 2)
			eventPlayer.targetType = TARGETS.STASH
			continue # bug
		else:
			eventPlayer.targetIndex = allTargets.index(eventPlayer.targetPos)

		# playEffect(eventPlayer, DynamicEffect.BAD_EXPLOSION, Color.PURPLE, eventPlayer.targetPos, 99)
			if eventPlayer.targetIndex == -1:
				continue
			if eventPlayer.targetIndex < DepositNo: # deposit
				eventPlayer.targetType = TARGETS.DEPOSIT
			elif eventPlayer.targetIndex == DepositNo: # overseer
				eventPlayer.targetType = TARGETS.OVERSEER
			elif eventPlayer.targetIndex == DepositNo + 1: # marketer
				eventPlayer.targetType = TARGETS.MARKET
		# else: # stash. removed because the re-setting caused stash hud to flicker
		# 	eventPlayer.targetIndex -= (DepositNo + 2)
		# 	eventPlayer.targetType = TARGETS.STASH
	while RULE_CONDITION

rule "take":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	@Condition not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
	@Condition not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	do:
		if eventPlayer.isCarryingStash:
			smallMessage(eventPlayer, "can't move resources while carrying stash.")
			cleanBeam()
			return
		# suck
		if eventPlayer.beamTarget == null:
			# new target
			if eventPlayer.targetType == TARGETS.STASH or eventPlayer.targetType == TARGETS.DEPOSIT:
				eventPlayer.beamTarget = eventPlayer.targetPos
				eventPlayer.beamTargetType = eventPlayer.targetType
				eventPlayer.beamTargetIndex = eventPlayer.targetIndex
				goto lbl_0
			else:
				return
		else:
			lbl_0:
			# los or distance
			if not isInLoS(eventPlayer.getEyePosition(), eventPlayer.beamTarget, BarrierLos.PASS_THROUGH_BARRIERS) or distance(eventPlayer, eventPlayer.beamTarget) > eventPlayer.takeRange:
				cleanBeam()
				return

			# calc take amt to prevent -ve value at source
			eventPlayer.moveAmt = min(eventPlayer.takeSpeed / 0.25 * 0.1,
				depositAmts[eventPlayer.beamTargetIndex] if eventPlayer.beamTargetType == TARGETS.DEPOSIT \
				else getPlayersInSlot(eventPlayer.beamTargetIndex, Team.ALL).stashContents[eventPlayer.resourceSel])

			# if eventPlayer.moveAmt == 0:
				# smallMessage(eventPlayer, "this {} has no more {} {}.".format(
				# 	"stash" if eventPlayer.beamTargetType == TARGETS.STASH else "deposit",
				# 	resourceIcons[eventPlayer.resourceSel], resourceNames[eventPlayer.resourceSel]
				# ))
				# cleanBeam()
				# return

			# switch to deposit resource
			if eventPlayer.beamTargetType == TARGETS.DEPOSIT:
				# if target moved
				if depositPos[eventPlayer.beamTargetIndex] != eventPlayer.beamTarget:
					cleanBeam()
					return
				eventPlayer.resourceSel = eventPlayer.beamTargetIndex % ResourceNo
			elif eventPlayer.moveAmt == 0:
				smallMessage(eventPlayer, "this {} has no more {} {}.".format(
					"stash", resourceIcons[eventPlayer.resourceSel], resourceNames[eventPlayer.resourceSel]
				))
				cleanBeam()
				return

			# check inventory space
			if eventPlayer.heldCap <= eventPlayer.heldContents[eventPlayer.resourceSel]:
				smallMessage(eventPlayer, "can't carry any more {} {}".format(resourceIcons[eventPlayer.resourceSel], resourceNames[eventPlayer.resourceSel]))
				eventPlayer.beamTarget = -1 # to retrigger rule
				wait(0.08)
				cleanBeam()
				eventPlayer.beamTargetType = TARGETS.NONE
				return

			# yoink
			eventPlayer.beamType = BEAMS.TAKE
			switch eventPlayer.beamTargetType:
				case TARGETS.DEPOSIT:
					depositAmts[eventPlayer.beamTargetIndex] -= eventPlayer.moveAmt
					break
				case TARGETS.STASH:
					getPlayersInSlot(eventPlayer.beamTargetIndex, Team.ALL).stashContents[eventPlayer.resourceSel] -= eventPlayer.moveAmt
					if eventPlayer.getSlot() != eventPlayer.beamTargetIndex:
						eventPlayer.naughty = true
					break

			eventPlayer.heldContents[eventPlayer.resourceSel] += eventPlayer.moveAmt
		wait(0.096)
	while RULE_CONDITION

rule "put":
	@Event eachPlayer
	@Condition not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	@Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
	@Condition not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	do:
		if eventPlayer.isCarryingStash:
			smallMessage(eventPlayer, "can't move resources while carrying stash.")
			cleanBeam()
			return

		# suck
		if eventPlayer.beamTarget == null:
			# new target
			if eventPlayer.targetType != TARGETS.NONE and eventPlayer.targetType != TARGETS.DEPOSIT:
				eventPlayer.beamTarget = eventPlayer.targetPos
				eventPlayer.beamTargetType = eventPlayer.targetType
				eventPlayer.beamTargetIndex = eventPlayer.targetIndex
				goto lbl_0
			else:
				return
		else:
			lbl_0:
			if eventPlayer.beamTargetType in [TARGETS.NONE, TARGETS.DEPOSIT]:
				return
			# los or distance
			if not isInLoS(eventPlayer.getEyePosition(), eventPlayer.beamTarget, BarrierLos.PASS_THROUGH_BARRIERS) or distance(eventPlayer, eventPlayer.beamTarget) > eventPlayer.takeRange:
				cleanBeam()
				return

			# switch to deposit resource
			if eventPlayer.beamTargetType == TARGETS.OVERSEER:
				eventPlayer.resourceSel = overseerWants

			# calc take amt to prevent -ve value in held
			eventPlayer.moveAmt = min(eventPlayer.putSpeed / 0.25 * 0.1, eventPlayer.heldContents[eventPlayer.resourceSel])

			if eventPlayer.moveAmt == 0:
				smallMessage(eventPlayer, "you don't have any more {} {}.".format(
					resourceIcons[eventPlayer.resourceSel], resourceNames[eventPlayer.resourceSel]
				))
				wait()
				cleanBeam()
				return
			# if target moved

			# ploink
			eventPlayer.beamType = BEAMS.PUT
			switch eventPlayer.beamTargetType:
				case TARGETS.OVERSEER:
					eventPlayer.money += eventPlayer.moveAmt * exchangeRate
					eventPlayer.loyaltyPoints += eventPlayer.moveAmt
					# eventPlayer.contributed_in_phase += eventPlayer.moveAmt
					break
				case TARGETS.STASH:
					# check stash space
					if getPlayersInSlot(eventPlayer.beamTargetIndex, Team.ALL).stashContents[eventPlayer.resourceSel] >= getPlayersInSlot(eventPlayer.beamTargetIndex, Team.ALL).stashCap:
						smallMessage(eventPlayer, "stash can't hold any more {} {}".format(resourceIcons[eventPlayer.resourceSel], resourceNames[eventPlayer.resourceSel]))
						cleanBeam()
						return
					getPlayersInSlot(eventPlayer.beamTargetIndex, Team.ALL).stashContents[eventPlayer.resourceSel] += eventPlayer.moveAmt
					break
				case TARGETS.MARKET:
					eventPlayer.naughty = true
					eventPlayer.money += eventPlayer.moveAmt * 1 # todo exchange rate
					break

			eventPlayer.heldContents[eventPlayer.resourceSel] -= eventPlayer.moveAmt
		wait(0.096)
	while RULE_CONDITION

rule "beam off cleanup":
	@Event eachPlayer
	@Condition not (eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)) \
	or eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	# smallMessage(hostPlayer, "cleanup")
	cleanBeam()
	# wait(0.16)

rule "interact npc":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.INTERACT)
	if distance(eventPlayer, techNPC) < 3:
		if eventPlayer.upgrades[sellingTech] < 10:
			if eventPlayer.money < round(eventPlayer.upgrades[sellingTech] + 2.5 * (eventPlayer.upgrades[sellingTech] ** 2)):
				smallMessage(eventPlayer, "{} you don't have enough money.".format(heroIcon(techNPC.getCurrentHero())))
			else:
				smallMessage(eventPlayer, "{} pleasure doing business with you.".format(heroIcon(techNPC.getCurrentHero())))

### deposits
rule "deposit tp debug":
	@Event eachPlayer
	@Disabled
	@Condition eventPlayer.isHoldingButton(Button.MELEE)
	eventPlayer.teleport(depositPos[eventPlayer.aiFaceTarget])
	eventPlayer.aiFaceTarget += 1
	eventPlayer.aiFaceTarget %= DepositNo
	smallMessage(eventPlayer, "{} entities | {}".format(getNumberOfEntityIds(), eventPlayer.aiFaceTarget))
	wait(1)

rule "spawn deposits":
	# if empty, inited or time to despawn
	while true:
		if depositAmts[i_deposit] <= 0 or depositDespawn[i_deposit] <= getTotalTimeElapsed():
			playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, resourceColors[i_deposit % ResourceNo], depositPos[i_deposit], 1)

			[x for x in getAllPlayers() if x.beamTarget == depositPos[i_deposit]].beamTarget = null
			[x for x in getAllPlayers() if x.targetPos == depositPos[i_deposit]].targetPos = null

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
			depositAmts[i_deposit] = (random.randint(1, 3) * 20 - random.randint(0, 7)) * ResourceScalar
			depositPos[i_deposit] = Gltemp1
			depositDespawn[i_deposit] = getTotalTimeElapsed() + 120

		i_deposit++
		i_deposit %= DepositNo
		wait(0.064)

### bots"
rule "spawn dummy":
	@Condition hostPlayer.isCommunicatingSpray()
	createDummy(Hero.SOLDIER, Team.ALL, -1, hostPlayer, Vector.UP)
rule "init orisas":
	@Event eachPlayer
	@Hero orisa
	@Condition eventPlayer.isDummy()
	@Condition eventPlayer.hasSpawned()
	eventPlayer.disableRespawn()
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 9999)
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
	@Condition eventPlayer.isDummy()
	@Condition eventPlayer != techNPC # need its variables for npc repos
	while true:
		eventPlayer.temp_2 = getPlayersInRadius(eventPlayer, 6, Team.ALL, LosCheck.SURFACES)
		# if (eventPlayer == techNPC and temp_2)
		if eventPlayer.getCurrentHero() == Hero.ORISA:
			eventPlayer.temp_2 = [x for x in eventPlayer.temp_2 if x.loyaltyRank >= 1]
			if eventPlayer.temp_2:
				eventPlayer.communicate(Comms.HELLO)
				smallMessage(eventPlayer.temp_2, "{}: {}".format(heroIcon(Hero.ORISA), random.choice(orisaQuips)))
		elif eventPlayer == marketNPC:
			eventPlayer.temp_2 = [x for x in eventPlayer.temp_2 if x.loyaltyRank < 0]
			if eventPlayer.temp_2:
				eventPlayer.communicate(Comms.HELLO)
				smallMessage(random.choice(eventPlayer.temp_2), "{} psst... wanna sell some resources?".format(heroIcon(eventPlayer.getCurrentHero())))

		wait(4.8)

rule "stop sombra stealth":
	while true:
		damage(getPlayersOnHero(Hero.SOMBRA, Team.ALL), null, 2)
		wait()
		heal(getPlayersOnHero(Hero.SOMBRA, Team.ALL), null, 10)
		wait(3)