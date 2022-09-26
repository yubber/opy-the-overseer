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
            "gamemodeStartTrigger": "immediately"
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

# total number of deposits
#!define DepositNo 12

rule getTakeTarget(): # temp_2 is list of candidate pos, temp_1 is output
	eventPlayer.temp_1 = sorted([x for x in temp_2
		if distance(x, eventPlayer) < eventPlayer.takeRange
		and eventPlayer.isInViewAngle(x, 90)
		and isInLoS(eventPlayer.getEyePosition(), x, BarrierLos.PASS_THROUGH_BARRIERS)]
		lambda y: angleBetweenVectors(eventPlayer.getFacingDirection(), y - eventPlayer.getPosition()))[0]

rule "global init":
	# disableInspector()
	disableGamemodeCompletion()
	disableScoring()
	setMatchTime(4*60+20)
	pauseMatchTime()
	spawn_center = Vecteur(146.990, 6, 251.050);
	defaultVect = Vecteur(139, 5.500, -283);

	patrollerNo = createWorkshopSetting(int[0:9], "")

	### deposits
	for i_init in range(DepositNo):
		resourcePos[i_init] = defaultVect
		createEffect(getAllPlayers(), Effect.SPHERE, resourceColors[evalOnce(i_init % DepositNo)], resourcePos[evalOnce(i_init % DepositNo)] + Vector.UP,
			0.5, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
		createEffect(getAllPlayers(), Effect.LIGHT_SHAFT, resourceColors[evalOnce(i_init % DepositNo)], resourcePos[evalOnce(i_init % DepositNo)] + Vector.DOWN * 15,
			0.5 + 0.001 * resourceAmts, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

		createInWorldText(getAllPlayers(), "{}: {}".format(evalOnce(resourceNames[i_init % DepositNo]), floor(resourceAmts[evalOnce(i_init % DepositNo)])),
			resourcePos[evalOnce(i_init % DepositNo)] + 1.5 * Vector.UP, 1.25, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
		wait()

	### overseer
	overseerPos = vect(143.490, 4.150, 247.490);

	overseerColor = random.choice([Color.BLUE, Color.YELLOW])
	createEffect(getAllPlayers(), Effect.BAD_AURA, overseerColor, overseerPos + Vector.UP, 3, EffectReeval.VISIBILITY)
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

	currentTech = -1;
	techPos = defaultVect;
	createDummy(random.choice(Hero.BRIGITTE, Hero.TORBJORN, Hero.SYMMETRA), Team.ALL, -1, defaultVect, Vector.DOWN)
	techNPC = getLastCreatedEntity()
	techNPC.startForcingName("technician")

	marketPos = defaultVect
	createDummy(random.choice(Hero.BAPTISTE, Hero.ANA, Hero.SOMBRA), Team.ALL, -1, defaultVect, Vector.DOWN)
	marketNPC = getLastCreatedEntity()
	marketNPC.startForcingName("black market trader")

	for i_init in range(patrollerNo):
		createDummy(Hero.ORISA, Team.ALL, -1, overseerPos, angleToDirection(random.uniform(0, 359.9), 0))

	hudText(getAllPlayers(), "\&fullwidth_space;", )
	for

rule "player spawn pos?":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	eventPlayer.temp_2 = random.uniform(5.205, 72)
	eventPlayer.temp_2 = 3 + (0.028 * eventPlayer.temp_2 ** 3 + -3.008 * eventPlayer.temp_2 ** 2 + 108 * eventPlayer.temp_2) / 72 + 0.500 * eventPlayer.temp_2;
	eventPlayer.temp_1 = spawnCenter + angleToDirection(random.uniform(0, 359.999), 0) * eventPlayer.temp_2
	eventPlayer.temp_2 = raycast(eventPlayer.temp_1, eventPlayer.temp_1 + Vector.DOWN * 10, [], [], false).getHitPosition()
	wait()
	if distance(eventPlayer.temp_1, eventPlayer.temp_2) <= 0.25:
		goto RULE_START
	eventPlayer.temp_2 = nearestWalkablePosition(eventPlayer.temp_2)

	# if too close to dealer, engineer, ???, any stash, or any deposit, pick a new spawn
	if distance(eventPlayer.temp_2, marketPos) <= 6.500 or distance(eventPlayer.temp_2, techPos) <= 6.500:
	or distance(eventPlayer.temp_2, vect(7.940, 26.980, 195.610)) <= 120 or distance(eventPlayer.temp_2, vect(86.150, 23.600, 113.380)) <= 120
	or any([distance(x, eventPlayer.temp_2) < 8 for x in stashesPos.exclude(0)])
	or any([distance(x, eventPlayer.temp_2) < 5 for x in resourcePos.exclude(defaultVect)]):
		goto RULE_START

	eventPlayer.stealingModif = 1

rule "player init":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.hasSpawned()

	eventPlayer.stashPos = temp_2;
	eventPlayer.oldStashPos = eventPlayer.stashPos
	eventPlayer.interest = 0.001 * 0.020 * distance(eventPlayer.stashPos, overseerPos) ** 2

	eventPlayer.setPrimaryFireEnabled(false)
	eventPlayer.setSecondaryFireEnabled(false)
	eventPlayer.setAbility1Enabled(false)
	eventPlayer.setAbility2Enabled(false)
	eventPlayer.setUltEnabled(false)

	eventPlayer.disableGamemodeHud()
	eventPlayer.disableHeroHUD()
	wait()
	techNPC.disableNameplatesFor(getAllPlayers())
	marketNPC.disableNameplatesFor(getAllPlayers())

	eventPlayer.disableRespawn()
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 3)
	eventPlayer.teleport(eventPlayer.stashPos)

	### ui
	# stash
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
	eventPlayer.stashTxt = getLastCreatedText()

	eventPlayer.fx = []
	createEffect(getAllPlayers(), Effect.SPHERE, Color.BLUE, eventPlayer.stashPos + Vector.UP, 2.2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	eventPlayer.fx.append(getLastCreatedEntity())

	# take beam
	createBeam(eventPlayer.takeBeamSeers, Beam.GOOD, eventPlayer + worldVector(vect(-0.225, 1.82, 0), eventPlayer, Transform.ROTATION_AND_TRANSLATION),
		eventPlayer.beamTarget + Vector.UP, resourceColors[eventPlayer.activeBeam], EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR)
	eventPlayer.fx.append(getLastCreatedEntity())

	# put beam, with start & end reversed

	bigMessage(eventPlayer, "THE OVERSEER {} {}".format(
		random.choice(["REQUIRES", "NEEDS", "DEMANDS", "CALLS FOR", "LACKS", "WANTS"]),
		resourceNames[overseerWants]
	))

rule "player spawned":
	@Event eachPlayer
	@Condition eventPlayer.isAlive
	eventPlayer.clearStatusEffect(Status.HACKED)
	wait()
	if eventPlayer.getCurrentHero() in [Hero.BAPTISTE, Hero.GENJI, Hero.LUCIO, Hero.HANZO, Hero.MERCY]:
		eventPlayer.setStatusEffect(null, Status.HACKED, 9999)

rule "take":
	@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	@Condition eventPlayer.beamCheckCd <= getTotalTimeElapsed()
	@Condition not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)
	if eventPlayer.carryingStash:
		smallMessage(eventPlayer, "can't use beam while carrying stash.")
	else:
		eventPlayer.beamCheckCd = getTotalTimeElapsed() + 0.256
		