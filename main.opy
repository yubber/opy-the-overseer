paramètres
{
	salon
	{
		Autoriser les joueurs en file d’attente: Oui
		Discussion audio de partie: Activé
		Inversion des équipes après une partie: Non
		Maximum de joueurs en Chacun pour soi: 8
		Retour au salon: Jamais
		Rotation des cartes: Après une partie
		Spectateurs max.: 12
	}

	modes
	{
		Combat à mort
		{
			Score à atteindre pour gagner: 20Apparition des kits de soins: Désactivé
			Barres de vie adverses: Désactivé
			Début de la partie: Immédiatement
		}

		Général
		{
			Limite de héros: Désactivé
		}
	}

	héros
	{
		Général
		{
			Coup en mêlée: Désactivé
			Dégâts infligés: 10%
			Durée de la capacité ultime: 25%
			Génération de capacité ultime: 10%
			Génération de capacité ultime - Combat: 0%
			Génération de capacité ultime - Passif: 0%
			Temps de recharge de la capacité: 500%
			Tir principal: Désactivé

			Écho
			{
				Planeur: Désactivé
			}
		}
	}
}

#!extension spawnMoreDummyBots

globalvar overseer_resource
globalvar spawn_center
globalvar temp_1
globalvar temp_2
globalvar temp_3
globalvar stash_positions
globalvar total_resources
globalvar resource_cooldown
globalvar resourceAmts
globalvar resource_despawn_times
globalvar previous_resource

globalvar resourceNames = [
	"minerals",
	"vespene gas",
	"gold",
	"lumber",
	"stone",
	"food"
]

globalvar resourceIcons = [

]

globalvar resourceColors = [
	Color.SKY_BLUE,
	Color.LIME_GREEN,
	Color.YELLOW,
	Color.ORANGE,
	Color.GRAY,
	Color.ROSE
]

globalvar rarity_index
globalvar rarity_pick_list
globalvar next_second
globalvar resourcePos
globalvar random_value
globalvar despawn_check
globalvar temp_effect_position
globalvar defaultVect
globalvar overseerPos
globalvar black_marketeer_player
globalvar currentTech
globalvar update_NPC_positions_command
globalvar tech_guy_player
globalvar black_marketeer_position
globalvar techPos
globalvar default_prices
globalvar last_round
globalvar seconds_left

playervar credits
playervar stash_position
playervar stash_resources
playervar stash_limit
playervar carry_resources
playervar carry_limit
playervar beam_check_cooldown
playervar beam_target
playervar who_can_see_harvest_beam
playervar active_beam_type
playervar primary_blocked
playervar harvest_power
playervar dispense_power
playervar harvest_length
playervar dispense_length
playervar update_stats_command
playervar upgrades
playervar beam_target_index
playervar resource_type
playervar who_can_see_stash_icon
playervar message_cooldown
playervar temp_effect_position
playervar sound_position
playervar secondary_blocked
playervar carrying_stash
playervar is_stealing
playervar who_can_see_dispense_beam
playervar stash_update_cooldown
playervar check_primary_on_stash
playervar previous_stash_position
playervar loyalty_hidden
playervar loyalty_rank
playervar check_secondary_delivery
playervar ult_button_duration
playervar crouch_pressed
playervar crouch_cooldown
playervar player_prices
playervar NPC_facing_target
playervar get_prices_command
playervar interest_rate
playervar crouch_hold_duration
playervar sprint_cooldown
playervar previous_loyalty_rank
playervar stealing_modifier
playervar contributed_in_phase
playervar spam_counter
playervar AI_cooldown
playervar AI_move_direction
playervar AI_current_angle
playervar AI_previous_position
playervar AI_facing_target
playervar update_facing_target_command
playervar stealing_cooldown
playervar spam_check
playervar greeting_cooldown
playervar stealing_from

# total number of deposits
#!define DepositNo 12

# ALL RESOURCE VALUES MULT BY 10 FOR PRECISION WHILE ROUNDING

rule "global init"
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

rule "player spawn pos?"
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	randomValue = random.uniform(5.205, 72)
	randomValue = 3 + (0.028 * randomValue ** 3 + -3.008 * randomValue ** 2 + 108 * randomValue) / 72 + 0.500 * randomValue;
	temp_1 = spawn_center + angleToDirection(random.uniform(0, 359.999), 0) * randomValue
	temp_2 = raycast(temp_1, temp_1 + Vector.DOWN * 10, [], [], false).getHitPosition()
	# wait()
	if distance(temp_1, temp_2) <= 0.25:
		goto RULE_START
	temp_2 = nearestWalkablePosition(temp_2)
	if distance(temp_2, marketPos) <= 6.500 or distance(temp_2, techPos) <= 6.500:
	or distance(temp_2, vect(7.940, 26.980, 195.610)) <= 120 or distance(temp_2, vect(86.150, 23.600, 113.380)) <= 120
	or any([distance(x, temp_2) < 8 for x in stashesPos.exclude(0)])
	or any([distance(x, temp_2) < 5 for x in resourcePos.exclude(defaultVect)])

	eventPlayer.stealingModif = 1

rule "player init"
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.hasSpawned()

	eventPlayer.stashPos = temp_2;
	eventPlayer.oldStashPos = eventPlayer.stashPos
	eventPlayer.interest = 0.001 * 0.020 * distance(eventPlayer.stashPos, overseerPos) ** 2
	eventPlayer.setPrimaryFireEnabled(false)
	eventPlayer.setSecondaryFireEnabled(false)
	if eventPlayer.getCurrentHero() == Hero.LUCIO:
		pass
	eventPlayer.setAbility1Enabled(false)
	eventPlayer.setAbility2Enabled(false)
	eventPlayer.setUltEnabled(false)

	eventPlayer.disableGamemodeHud()
	eventPlayer.disableHeroHUD()

	techNPC.disableNameplatesFor(getAllPlayers())
	marketNPC.disableNameplatesFor(getAllPlayers())

	eventPlayer.disableRespawn()
	eventPlayer.setStatusEffect(null, Status.INVINCIBLE, 3)
		Téléportation(Joueur exécutant, Joueur exécutant.stash_position);
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

		createEffect()

		Créer un effet(Tous les joueurs(Équipe 1), Sphère, Couleur(Bleu), Joueur exécutant.stash_position + Haut, 2.200,
			Visible pour Position et Rayon);
		Créer un effet de rayon(Joueur exécutant.who_can_see_harvest_beam, Bon rayon, Joueur exécutant + Vecteur(0, 1.820, 0)
			+ Vecteur mondial de(Vecteur(-0.225, 0, 0), Joueur exécutant, Rotation) + Direction depuis des angles(
			Angle horizontal du regard de(Joueur exécutant), Angle vertical du regard de(Joueur exécutant) + 10),
			Joueur exécutant.beam_target + Haut, Couleur(Cyan), Visible pour Position et Rayon);
		Créer un effet de rayon(Joueur exécutant.who_can_see_dispense_beam, Mauvais rayon, Joueur exécutant + Vecteur(0, 1.820, 0)
			+ Vecteur mondial de(Vecteur(-0.225, 0, 0), Joueur exécutant, Rotation) + Direction depuis des angles(
			Angle horizontal du regard de(Joueur exécutant), Angle vertical du regard de(Joueur exécutant) + 10),
			Joueur exécutant.beam_target + Haut, Couleur(Cyan), Visible pour Position et Rayon);
		Joueur exécutant.update_stats_command = Vrai;
		Créer une icône(Joueur exécutant.who_can_see_stash_icon, Joueur exécutant.stash_position, Poubelle, Visible pour et Position,
			Couleur(Bleu), Vrai);
		Joueur exécutant.who_can_see_stash_icon = Joueur exécutant;
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Créer un effet(Tous les joueurs(Équipe 1), Son de l’énergie, Couleur(Blanc), Joueur exécutant.sound_position, 200,
			Visible pour Position et Rayon);
		Créer du texte d’interface(Joueur exécutant, Chaîne personnalisée("Beam Setting: {0}", Joueur exécutant.resource_type + 1),
			Non applicable, Non applicable, Gauche, 0, Couleur(Blanc), Couleur(Blanc), Couleur(Blanc), Chaîne de texte,
			Visibilité par défaut);
		Créer du texte d’interface(Joueur exécutant, Chaîne personnalisée("Overseer resource: {0}", previous_resource),
			Chaîne personnalisée("Reward (100 units): {0} credits", Arrondir à l’entier(Joueur exécutant.player_prices[6] * 100,
			Au plus près)), Chaîne personnalisée("Seconds left: {0}", seconds_left), Haut, -2, Couleur(Blanc), Couleur(Blanc),
			Couleur(Blanc), Chaîne de texte, Visibilité par défaut);
		Créer du texte d’interface(Joueur exécutant, Non applicable, Non applicable, Chaîne personnalisée(
			"Credits: {1}\r\nLoyalty Rank: {0}", Joueur exécutant.loyalty_rank, Arrondir à l’entier(Joueur exécutant.credits, En dessous)),
			Droite, -1, Couleur(Blanc), Couleur(Blanc), Couleur(Blanc), Chaîne de texte, Visibilité par défaut);
		Joueur exécutant.stash_update_cooldown = Vrai;
		Passer si(next_second > 0, 2);
		seconds_left = 10;
		next_second = Temps total écoulé + 1;
		Attente(3, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Stash Interest Rate: {0}% per phase",
			Joueur exécutant.interest_rate * 100));
		Interrompre si(seconds_left <= 10);

		bigMessage(eventPlayer, "THE OVERSEER {} {}".format(
			random.choice(["REQUIRES", "NEEDS", "DEMANDS", "CALLS FOR", "LACKS", "WANTS"]),
			resourceNames[overseerWants]
		))

règle("Primary - Get Resource from Node - Beam Type 1")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Les deux;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Tir principal)) == Vrai;
		Joueur exécutant.beam_check_cooldown <= Temps total écoulé;
		Joueur exécutant.primary_blocked == Faux;
		Joueur exécutant.active_beam_type <= 1;
	}

	actions
	{
		Interrompre si(Joueur exécutant.carrying_stash == Vrai);
		Joueur exécutant.beam_check_cooldown = Temps total écoulé + 0.250;
		Passer si(Joueur exécutant.active_beam_type == 1, 2);
		temp_1 = Premier de(Tableau trié(Tableau filtré(Supprimer du tableau(resourcePos, zero_vector),
			Dans le champ de vision(Joueur exécutant, Élément de tableau actuel, 90) && Distance entre(Élément de tableau actuel,
			Joueur exécutant) <= Joueur exécutant.harvest_length && Dans la ligne de vue(Position des yeux(Joueur exécutant),
			Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(
			Joueur exécutant), Élément de tableau actuel + Haut) + -0.500), Les barrières ne bloquent pas la ligne de vue)
			&& Distance entre(Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(
			Élément de tableau actuel + Vecteur(0, 1, 0) - Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)),
			Élément de tableau actuel + Vecteur(0, 1, 0)) <= 0.625), Angle entre deux vecteurs(Regard en direction de(Joueur exécutant),
			Direction(Position des yeux(Joueur exécutant), Élément de tableau actuel + Vecteur(0, 1, 0)))));
		Passer(1);
		temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
			<= Joueur exécutant.harvest_length + 0.250);
		Passer si(temp_1 == Vrai, 7);
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Joueur exécutant.who_can_see_harvest_beam = Non applicable;
		Passer si(Joueur exécutant.active_beam_type == Vrai, 1);
		Joueur exécutant.check_primary_on_stash = Vrai;
		Joueur exécutant.active_beam_type = Faux;
		Joueur exécutant.primary_blocked = Vrai;
		Interrompre;
		resource_despawn_times[Joueur exécutant.beam_target_index] = Temps total écoulé + 60;
		Passer si(Joueur exécutant.active_beam_type != 1, 36);
		temp_3 = Joueur exécutant.harvest_power;
		Passer si(
			Joueur exécutant.harvest_power <= Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type],
			4);
		temp_3 = Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
		Passer si(
			Joueur exécutant.carry_resources[Joueur exécutant.resource_type] < Joueur exécutant.carry_limit || Joueur exécutant.message_cooldown > Temps total écoulé,
			2);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Carrying capacity reached"));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Passer si(temp_3 < resourceAmts[Joueur exécutant.beam_target_index], 25);
		temp_2 = resourceAmts[Joueur exécutant.beam_target_index];
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Joueur exécutant.temp_effect_position = resourcePos[Joueur exécutant.beam_target_index];
		Jouer un effet(Tous les joueurs(Équipe 1), Son d’explosion d’amélioration, Couleur(Blanc), Joueur exécutant.temp_effect_position,
			50);
		Passer(Joueur exécutant.resource_type * 2 + 1);
		Interrompre;
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Bleu ciel), Joueur exécutant.temp_effect_position, 1);
		Passer(9);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Vert), Joueur exécutant.temp_effect_position, 1);
		Passer(7);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Orange), Joueur exécutant.temp_effect_position, 1);
		Passer(5);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Citron vert), Joueur exécutant.temp_effect_position, 1);
		Passer(3);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Blanc), Joueur exécutant.temp_effect_position, 1);
		Passer(1);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Rouge), Joueur exécutant.temp_effect_position, 1);
		resourcePos[Joueur exécutant.beam_target_index] = zero_vector;
		resourceAmts[Joueur exécutant.beam_target_index] = Faux;
		resource_despawn_times[temp_2] = 0;
		total_resources -= 1;
		Joueur exécutant.who_can_see_harvest_beam = Non applicable;
		Joueur exécutant.active_beam_type = 1;
		Joueur exécutant.primary_blocked = Vrai;
		Passer(2);
		temp_2 = temp_3;
		resourceAmts[Joueur exécutant.beam_target_index] -= temp_2;
		Joueur exécutant.carry_resources[Joueur exécutant.resource_type] += temp_2;
		Interrompre;
		Joueur exécutant.beam_target = temp_1;
		Joueur exécutant.beam_target_index = Index de la valeur de tableau(resourcePos, temp_1);
		Joueur exécutant.resource_type = Arrondir à l’entier(Joueur exécutant.beam_target_index * 0.500, En dessous);
		Joueur exécutant.who_can_see_harvest_beam = Tous les joueurs(Équipe 1);
		Joueur exécutant.active_beam_type = 1;
		Joueur exécutant.sound_position = Joueur exécutant.beam_target;
	}
}

règle("Primary - Get Resource from Stash - Beam Type 2")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Tir principal)) == Vrai;
		(Joueur exécutant.beam_check_cooldown <= Temps total écoulé || Joueur exécutant.check_primary_on_stash == Vrai) == Vrai;
		Joueur exécutant.active_beam_type != 1;
		Joueur exécutant.active_beam_type <= 2;
	}

	actions
	{
		Passer si(Joueur exécutant.check_primary_on_stash == Vrai || Joueur exécutant.active_beam_type == Faux, 2);
		Joueur exécutant.beam_check_cooldown = Temps total écoulé + 0.250;
		Passer(1);
		Joueur exécutant.check_primary_on_stash = Faux;
		Passer si(Joueur exécutant.active_beam_type == 2, 3);
		temp_1 = Premier de(Tableau trié(Tableau filtré(Supprimer du tableau(stash_positions, 0), Dans le champ de vision(
			Joueur exécutant, Élément de tableau actuel, 90) && Distance entre(Élément de tableau actuel, Joueur exécutant)
			<= Joueur exécutant.harvest_length && Dans la ligne de vue(Position des yeux(Joueur exécutant), Position des yeux(
			Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Haut) + -1), Les barrières ne bloquent pas la ligne de vue) && Distance entre(Position des yeux(
			Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(Élément de tableau actuel + Vecteur(0, 1, 0)
			- Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)), Élément de tableau actuel + Vecteur(0, 1, 0))
			<= 2.750), Angle entre deux vecteurs(Regard en direction de(Joueur exécutant), Direction(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Vecteur(0, 1, 0)))));
		Joueur exécutant.beam_target_index = Index de la valeur de tableau(stash_positions, temp_1);
		Passer(1);
		temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
			<= Joueur exécutant.harvest_length + 0.250);
		Passer si(temp_1 == Vrai && Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type] > 0, 6);
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Joueur exécutant.who_can_see_harvest_beam = Non applicable;
		Joueur exécutant.active_beam_type = Faux;
		Joueur exécutant.primary_blocked = Vrai;
		Joueur exécutant.is_stealing = Faux;
		Interrompre;
		Passer si(Joueur exécutant.active_beam_type != 2, 15);
		temp_3 = Joueur exécutant.harvest_power;
		Passer si(
			Joueur exécutant.harvest_power <= Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type],
			4);
		temp_3 = Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
		Passer si(
			Joueur exécutant.carry_resources[Joueur exécutant.resource_type] < Joueur exécutant.carry_limit || Joueur exécutant.message_cooldown > Temps total écoulé,
			2);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Carrying capacity reached"));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Passer si(temp_3 < Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type], 3);
		temp_2 = Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type];
		Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1).stash_resources[Joueur exécutant.resource_type] = 0;
		Passer(2);
		temp_2 = temp_3;
		Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type] -= temp_2;
		Joueur exécutant.carry_resources[Joueur exécutant.resource_type] += temp_2;
		Joueur exécutant.loyalty_hidden -= Joueur exécutant.is_stealing * temp_2 * Joueur exécutant.stealing_modifier * 2;
		Interrompre;
		Joueur exécutant.beam_target = temp_1;
		Joueur exécutant.who_can_see_harvest_beam = Tous les joueurs(Équipe 1);
		Joueur exécutant.active_beam_type = 2;
		Joueur exécutant.sound_position = Joueur exécutant.beam_target;
		Interrompre si(Joueur exécutant.beam_target_index == Emplacement de(Joueur exécutant));
		Joueur exécutant.is_stealing = Vrai;
	}
}

règle("Secondary - Put Resource Into Stash - Beam Type 3")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Tir secondaire)) == Vrai;
		Joueur exécutant.beam_check_cooldown <= Temps total écoulé;
		Joueur exécutant.secondary_blocked == Faux;
		(Joueur exécutant.active_beam_type == 0 || Joueur exécutant.active_beam_type == 3) == Vrai;
	}

	actions
	{
		Interrompre si(Joueur exécutant.active_beam_type > 0 && Joueur exécutant.active_beam_type != 3);
		Joueur exécutant.beam_check_cooldown = Temps total écoulé + 0.250;
		Passer si(Joueur exécutant.active_beam_type == 3, 3);
		temp_1 = Premier de(Tableau trié(Tableau filtré(Supprimer du tableau(stash_positions, 0), Dans le champ de vision(
			Joueur exécutant, Élément de tableau actuel, 90) && Distance entre(Élément de tableau actuel, Joueur exécutant)
			<= Joueur exécutant.dispense_length && Dans la ligne de vue(Position des yeux(Joueur exécutant), Position des yeux(
			Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Haut) + -1), Les barrières ne bloquent pas la ligne de vue) && Distance entre(Position des yeux(
			Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(Élément de tableau actuel + Vecteur(0, 1, 0)
			- Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)), Élément de tableau actuel + Vecteur(0, 1, 0))
			<= 2.750), Angle entre deux vecteurs(Regard en direction de(Joueur exécutant), Direction(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Vecteur(0, 1, 0)))));
		Joueur exécutant.beam_target_index = Index de la valeur de tableau(stash_positions, temp_1);
		Passer(1);
		temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
			<= Joueur exécutant.dispense_length + 0.250);
		Passer si(temp_1 == Vrai && Joueur exécutant.carry_resources[Joueur exécutant.resource_type] > 0, 7);
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Joueur exécutant.who_can_see_dispense_beam = Non applicable;
		Passer si(Joueur exécutant.active_beam_type == Vrai, 1);
		Joueur exécutant.check_secondary_delivery = Vrai;
		Joueur exécutant.active_beam_type = Faux;
		Joueur exécutant.secondary_blocked = Vrai;
		Interrompre;
		Passer si(Joueur exécutant.active_beam_type != 3, 14);
		temp_3 = Joueur exécutant.dispense_power;
		Passer si(Joueur exécutant.dispense_power <= Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_limit - Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type], 4);
		temp_3 = Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1).stash_limit - Joueurs dans l’emplacement(
			Joueur exécutant.beam_target_index, Équipe 1).stash_resources[Joueur exécutant.resource_type];
		Passer si(Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type] < Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_limit || Joueur exécutant.message_cooldown > Temps total écoulé, 2);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Stash capacity reached"));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Passer si(temp_3 < Joueur exécutant.carry_resources[Joueur exécutant.resource_type], 3);
		temp_2 = Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
		Joueur exécutant.carry_resources[Joueur exécutant.resource_type] = 0;
		Passer(2);
		temp_2 = temp_3;
		Joueur exécutant.carry_resources[Joueur exécutant.resource_type] -= temp_2;
		Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
			.stash_resources[Joueur exécutant.resource_type] += temp_2;
		Interrompre;
		Joueur exécutant.beam_target = temp_1;
		Joueur exécutant.who_can_see_dispense_beam = Tous les joueurs(Équipe 1);
		Joueur exécutant.active_beam_type = 3;
		Joueur exécutant.sound_position = Joueur exécutant.beam_target;
	}
}

règle("Secondary - Deliver Resource to Overseer / Black Marketeer - Beam Type 4")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Tir secondaire)) == Vrai;
		(Joueur exécutant.beam_check_cooldown <= Temps total écoulé || Joueur exécutant.check_secondary_delivery == Vrai) == Vrai;
		(Joueur exécutant.active_beam_type == 0 || Joueur exécutant.active_beam_type >= 4) == Vrai;
	}

	actions
	{
		Passer si(Joueur exécutant.check_secondary_delivery == Vrai || Joueur exécutant.active_beam_type == Faux, 2);
		Joueur exécutant.beam_check_cooldown = Temps total écoulé + 0.250;
		Passer(1);
		Joueur exécutant.check_secondary_delivery = Faux;
		Passer si(Joueur exécutant.active_beam_type >= 4, 4);
		temp_1 = Tableau filtré(overseerPos, Dans le champ de vision(Joueur exécutant, overseerPos, 90)
			&& Distance entre(overseerPos, Joueur exécutant) <= Joueur exécutant.dispense_length && Dans la ligne de vue(
			Position des yeux(Joueur exécutant), Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * (
			Distance entre(Position des yeux(Joueur exécutant), overseerPos + Haut) + -1),
			Les barrières ne bloquent pas la ligne de vue) && Distance entre(Position des yeux(Joueur exécutant) + Regard en direction de(
			Joueur exécutant) * Produit scalaire(overseerPos + Haut - Position des yeux(Joueur exécutant),
			Regard en direction de(Joueur exécutant)), overseerPos + Haut) <= 3);
		Passer si(temp_1 != Tableau vide, 1);
		temp_1 = Tableau filtré(black_marketeer_position, Dans le champ de vision(Joueur exécutant,
			black_marketeer_position, 90) && Distance entre(black_marketeer_position, Joueur exécutant)
			<= Joueur exécutant.dispense_length && Dans la ligne de vue(Position des yeux(Joueur exécutant), Position des yeux(
			Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(Joueur exécutant),
			black_marketeer_position + Haut) + -1), Les barrières ne bloquent pas la ligne de vue) && Distance entre(
			Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(
			black_marketeer_position + Haut - Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)),
			black_marketeer_position + Haut) <= 3);
		Passer(1);
		temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
			<= Joueur exécutant.dispense_length + 0.250 && (
			Joueur exécutant.beam_target == overseerPos || Joueur exécutant.beam_target == black_marketeer_position));
		Passer si(temp_1 == Vrai && ((
			temp_1 == overseerPos && Joueur exécutant.carry_resources[previous_resource + -1] > 0) || (
			temp_1 != overseerPos && Joueur exécutant.carry_resources[Joueur exécutant.resource_type] > 0)), 6);
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Joueur exécutant.who_can_see_dispense_beam = Non applicable;
		Joueur exécutant.active_beam_type = Faux;
		Joueur exécutant.secondary_blocked = Vrai;
		Joueur exécutant.is_stealing = Faux;
		Interrompre;
		Passer si(Joueur exécutant.active_beam_type < 4, 14);
		temp_3 = Joueur exécutant.dispense_power;
		Passer si(temp_3 < Joueur exécutant.carry_resources[Joueur exécutant.resource_type], 3);
		temp_3 = Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
		Joueur exécutant.carry_resources[Joueur exécutant.resource_type] = 0;
		Passer(1);
		Joueur exécutant.carry_resources[Joueur exécutant.resource_type] -= temp_3;
		Passer si(Joueur exécutant.active_beam_type > 4, 4);
		Joueur exécutant.credits += temp_3 * Joueur exécutant.player_prices[6];
		Joueur exécutant.loyalty_hidden += temp_3;
		Joueur exécutant.contributed_in_phase += temp_3;
		Interrompre;
		Joueur exécutant.credits += temp_3 * Joueur exécutant.player_prices[Joueur exécutant.resource_type];
		Joueur exécutant.loyalty_hidden -= temp_3 * Joueur exécutant.stealing_modifier * (0.200 + (
			Joueur exécutant.resource_type == previous_resource + -1) * 0.800);
		Interrompre;
		Joueur exécutant.beam_target = temp_1;
		Joueur exécutant.resource_type = (temp_1 == overseerPos) * (previous_resource + -1) + (
			temp_1 != overseerPos) * Joueur exécutant.resource_type;
		Joueur exécutant.who_can_see_dispense_beam = Tous les joueurs(Équipe 1);
		Joueur exécutant.active_beam_type = 4 + (temp_1 != overseerPos) * 1;
		Joueur exécutant.is_stealing = Joueur exécutant.active_beam_type == 5;
		Joueur exécutant.sound_position = Joueur exécutant.beam_target;
	}
}

rule "release primary fire":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

	# Interrompre si(Joueur exécutant.active_beam_type >= 3);
	eventPlayer.primaryBlocked = false;
	if eventPlayer.activeBeamType > -1:
		eventPlayer.takeBeamSeers = [];
		eventPlayer.activeBeamType = -1;
		eventPlayer.soundPos = Vector.UP * getTotalTimeElapsed();
		eventPlayer.takingFromStash = false;
		eventPlayer.stealing = false;

rule "release secondary"
	@Event eachPlayer
	@Condition not eventPlayer.isFiringSecondaryFire()
	# Interrompre si(Joueur exécutant.active_beam_type >= 1 && Joueur exécutant.active_beam_type <= 2);
	eventPlayer.secondary_blocked = Faux;
	# Interrompre si(eventPlayer..active_beam_type == Faux);
	if eventPlayer.activeBeamType > -1:
		eventPlayer.putBeamSeers = [];
		eventPlayer.activeBeamType = -1;
		eventPlayer.soundPos = Vector.UP * getTotalTimeElapsed();
		eventPlayer.delivering = false;
		eventPlayer.stealing = false

règle("Spawn Resources")
{
	évènement
	{
		Toute la partie - Tout le monde;
	}

	conditions
	{
		resource_cooldown <= Temps total écoulé;
		total_resources < 12;
	}

	actions
	{
		Attente(0.250, Ignorer la condition);
		random_value = Nombre réel aléatoire(2, 72);
		random_value = 3 + (0.028 * random_value ^ 3 + -3.008 * random_value ^ 2 + 108 * random_value)
			/ 72 + 0.500 * random_value;
		temp_1 = Valeur aléatoire dans le tableau(Tableau filtré(numbers_0_11,
			resourceAmts[Élément de tableau actuel] == Faux));
		temp_2 = spawn_center + Direction depuis des angles(Nombre réel aléatoire(0, 359.999), 0) * random_value;
		temp_3 = Position d’impact du rayon émis(temp_2, temp_2 + Vecteur(0, -10, 0), Non applicable, Non applicable,
			Faux);
		Boucle si(Distance entre(temp_2, temp_3) <= 0.250);
		temp_3 = Position la plus proche en marchant(temp_3);
		Boucle si(Vrai pour n’importe qui(Supprimer du tableau(stash_positions, 0), Distance entre(Élément de tableau actuel,
			temp_3) < 8));
		Boucle si(Vrai pour n’importe qui(Supprimer du tableau(resourcePos, zero_vector), Distance entre(
			Élément de tableau actuel, temp_3) < 5));
		Boucle si(Distance entre(temp_2, black_marketeer_position) <= 6.500 || Distance entre(temp_2,
			techPos) <= 6.500);
		despawn_check += (despawn_check <= Temps total écoulé + 0.500) * 0.500;
		resourceAmts[temp_1] = Nombre entier aléatoire(1, 3) * 20 - Nombre entier aléatoire(0, 7);
		total_resources += 1;
		resource_cooldown = Temps total écoulé + 0.750;
		resourcePos[temp_1] = temp_3;
		resource_despawn_times[temp_1] = Temps total écoulé + 120;
	}
}

règle("Player Changes Beam Setting: Ability 2")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Capacité 2)) == Vrai;
		Joueur exécutant.active_beam_type == Faux;
	}

	actions
	{
		Joueur exécutant.resource_type = (Joueur exécutant.resource_type + 1) * (Joueur exécutant.resource_type <= 4);
	}
}

règle("Player Changes Beam Setting: Interact")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Interaction)) == Vrai;
		Joueur exécutant.active_beam_type == Faux;
	}

	actions
	{
		Joueur exécutant.resource_type = Joueur exécutant.resource_type + -1 + (Joueur exécutant.resource_type <= 0) * 6;
	}
}

règle("Despawn Inactive Resources")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		despawn_check <= Temps total écoulé;
	}

	actions
	{
		despawn_check = Temps total écoulé + 1;
		temp_1 = Tableau trié(Tableau filtré(Supprimer du tableau(resource_despawn_times, 0),
			Élément de tableau actuel <= Temps total écoulé), Élément de tableau actuel);
		Interrompre si(temp_1 == Tableau vide);
		temp_1 = Premier de(temp_1);
		temp_2 = Index de la valeur de tableau(resource_despawn_times, temp_1);
		resource_despawn_times[temp_2] = 0;
		temp_effect_position = resourcePos[temp_2];
		resourcePos[temp_2] = zero_vector;
		resourceAmts[temp_2] = 0;
		Passer(Arrondir à l’entier(temp_2 * 0.500, En dessous) * 2 + 1);
		Interrompre;
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Bleu ciel), temp_effect_position, 1);
		Passer(9);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Vert), temp_effect_position, 1);
		Passer(7);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Orange), temp_effect_position, 1);
		Passer(5);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Citron vert), temp_effect_position, 1);
		Passer(3);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Blanc), temp_effect_position, 1);
		Passer(1);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Rouge), temp_effect_position, 1);
		total_resources -= 1;
	}
}

règle("Player Left Match")
{
	évènement
	{
		Un joueur a quitté la partie;
		Équipe 1;
		Tout;
	}

	actions
	{
		stash_positions[Emplacement de(Joueur exécutant)] = 0;
	}
}

règle("Update Loyalty Rank")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.stash_update_cooldown == Vrai;
		Joueur exécutant.stash_update_cooldown <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.stash_update_cooldown = Temps total écoulé + 2;
		Joueur exécutant.spam_counter -= Joueur exécutant.spam_counter == Vrai;
		temp_1 = Joueur exécutant.loyalty_hidden * 0.040;
		Joueur exécutant.loyalty_rank = Arrondir à l’entier(-0.008 * temp_1 * Valeur absolue(temp_1) + 0.800 * temp_1,
			Au plus près);
		Passer si(Valeur absolue(Joueur exécutant.loyalty_hidden) <= 1250, 1);
		Joueur exécutant.loyalty_rank = 20 + (Joueur exécutant.loyalty_hidden < 0) * -40;
		Interrompre si(Joueur exécutant.loyalty_rank == Joueur exécutant.previous_loyalty_rank);
		Joueur exécutant.get_prices_command += 1;
		Joueur exécutant.previous_loyalty_rank = Joueur exécutant.loyalty_rank;
		Joueur exécutant.stealing_modifier = 1 + (Joueur exécutant.loyalty_rank >= 1) * (Joueur exécutant.previous_loyalty_rank + -0.500);
	}
}

règle("You Shall Not Touch the Overseer")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Distance entre(Joueur exécutant, overseerPos + Bas) <= 3;
	}

	actions
	{
		Interrompre si(Joueur exécutant.message_cooldown > Temps total écoulé);
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Passer si(Joueur exécutant.loyalty_rank >= 20, 3);
		Tuer(Joueur exécutant, Non applicable);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Only those who are truly loyal may approach the Overseer."));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("You are truly loyal"));
	}
}

règle("Player Died")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Points de vie(Joueur exécutant) == Faux;
	}

	actions
	{
		Attente(3, Ignorer la condition);
		Boucle si(Joueur exécutant.previous_stash_position == 0);
		Téléportation(Joueur exécutant, Joueur exécutant.previous_stash_position);
		Définir un statut(Joueur exécutant, Non applicable, Invincible, 3);
		Ressusciter(Joueur exécutant);
	}
}

règle("Sprint")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Capacité 1)) == Vrai;
	}

	actions
	{
		Interrompre si(Joueur exécutant.carrying_stash == Vrai);
		Interrompre si(Joueur exécutant.sprint_cooldown > Temps total écoulé);
		Joueur exécutant.sprint_cooldown = Temps total écoulé + 15;
		Définir l’activation de la capacité 1(Joueur exécutant, Faux);
		Définir la vitesse de déplacement(Joueur exécutant, (100 + Joueur exécutant.upgrades[2] * 10) * 1.500);
	}
}

règle("Sprint Ends")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.sprint_cooldown <= Temps total écoulé + 12.500;
	}

	actions
	{
		Définir la vitesse de déplacement(Joueur exécutant, (100 + Joueur exécutant.upgrades[2] * 10) * (1 + -0.300 * (
			Joueur exécutant.carrying_stash == Vrai)));
	}
}

règle("Sprint Cooldown")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.sprint_cooldown <= Temps total écoulé;
	}

	actions
	{
		Interrompre si(Joueur exécutant.carrying_stash == Vrai);
		Définir l’activation de la capacité 1(Joueur exécutant, Vrai);
	}
}

règle("Ultimate Button: Delete Carried Resources")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(Capacité ultime)) == Vrai;
	}

	actions
	{
		Interrompre si(Vrai pour tous(Joueur exécutant.carry_resources, Élément de tableau actuel <= 0)
			|| Joueur exécutant.carry_resources == 0);
		Attente(0.250, Ignorer la condition);
		Joueur exécutant.ult_button_duration += 1;
		Passer si(Joueur exécutant.ult_button_duration < 4, 4);
		Jouer un effet(Joueur exécutant, Son de l’explosion, Couleur(Blanc), Joueur exécutant, 50);
		Joueur exécutant.carry_resources = 0;
		Joueur exécutant.ult_button_duration = 0;
		Interrompre;
		Boucle si(Bouton maintenu enfoncé(Joueur exécutant, Bouton(Capacité ultime)) == Vrai);
		Joueur exécutant.ult_button_duration = 0;
	}
}

règle("")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(S’accroupir)) == Vrai;
		Joueur exécutant.crouch_pressed == Faux;
	}

	actions
	{
		Joueur exécutant.crouch_pressed = Vrai;
		Interrompre si(Points de vie(Joueur exécutant) == Faux);
		Interrompre si(Joueur exécutant.crouch_cooldown > Temps total écoulé);
		Passer si(Joueur exécutant.carrying_stash == Vrai, 16);
		Passer si(Distance entre(Joueur exécutant, Joueur exécutant.stash_position) > 3, 35);
		Joueur exécutant.crouch_cooldown = Temps total écoulé + 0.250;
		Passer si(Vrai pour tous(Joueur exécutant.carry_resources, Élément de tableau actuel < 1) || Joueur exécutant.carry_resources == 0,
			4);
		Passer si(Joueur exécutant.message_cooldown > Temps total écoulé, 2);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Cannot carry stash while carrying other resources"));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Interrompre;
		Définir l’activation de la capacité 1(Joueur exécutant, Faux);
		Jouer un effet(Joueur exécutant, Son d’impact d’amélioration, Couleur(Blanc), Joueur exécutant, 50);
		stash_positions[Emplacement de(Joueur exécutant)] = 0;
		Joueur exécutant.carry_resources = 0;
		Joueur exécutant.stash_position = zero_vector;
		Joueur exécutant.carrying_stash = Vrai;
		Définir la vitesse de déplacement(Joueur exécutant, (100 + Joueur exécutant.upgrades[2] * 10) * (
			1 + Joueur exécutant.carrying_stash * -0.300));
		Joueur exécutant.who_can_see_stash_icon = Non applicable;
		Interrompre;
		Joueur exécutant.crouch_cooldown = Temps total écoulé + 0.250;
		temp_1 = Position d’impact du rayon émis(Joueur exécutant + Haut, Joueur exécutant + Vecteur(0, -10, 0), Non applicable,
			Non applicable, Faux);
		Passer si(Distance entre(temp_1, techPos) > 6.500 && Distance entre(temp_1,
			black_marketeer_position) > 6.500 && Vrai pour tous(Supprimer du tableau(stash_positions, 0), Distance entre(
			Élément de tableau actuel, temp_1) >= 8) && Vrai pour tous(resourcePos, Distance entre(
			Élément de tableau actuel, temp_1) >= 5) && Distance entre(overseerPos, temp_1)
			>= 12.333 && Composante Y de(temp_1) >= 0.500 && Composante Y de(temp_1) <= 7, 4);
		Passer si(Joueur exécutant.message_cooldown > Temps total écoulé, 2);
		Message en petit(Joueur exécutant, Chaîne personnalisée("You cannot place your stash here"));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Interrompre;
		Joueur exécutant.crouch_cooldown = Temps total écoulé + 1;
		Jouer un effet(Joueur exécutant, Son d’explosion concentrique, Couleur(Blanc), Joueur exécutant, 50);
		Joueur exécutant.who_can_see_stash_icon = Joueur exécutant;
		Définir l’activation de la capacité 1(Joueur exécutant, Joueur exécutant.sprint_cooldown <= Temps total écoulé);
		Joueur exécutant.carrying_stash = Faux;
		Joueur exécutant.stash_position = temp_1;
		Joueur exécutant.previous_stash_position = temp_1;
		stash_positions[Emplacement de(Joueur exécutant)] = temp_1;
		Définir la vitesse de déplacement(Joueur exécutant, 100 + Joueur exécutant.upgrades[2] * 10);
		Jouer un effet(Tous les joueurs(Équipe 1), Explosion concentrique, Couleur(Bleu), Joueur exécutant.stash_position + Haut, 8);
		Joueur exécutant.interest_rate = 0.001 * 0.020 * Distance entre(Joueur exécutant.stash_position, overseerPos)
			* Distance entre(Joueur exécutant.stash_position, overseerPos);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Stash Interest Rate: {0}% per phase",
			Joueur exécutant.interest_rate * 100));
		Interrompre;
		Passer si(Distance entre(Joueur exécutant, techPos) > 3.500 || Dans la ligne de vue(Position des yeux(
			Joueur exécutant), techPos + Haut, Les barrières ne bloquent pas la ligne de vue) == Faux, 2);
		Joueur exécutant.crouch_hold_duration = Temps total écoulé;
		Interrompre;
		Interrompre si(Distance entre(Joueur exécutant, black_marketeer_position) > 3.500 || Dans la ligne de vue(Position des yeux(
			Joueur exécutant), black_marketeer_position + Haut, Les barrières ne bloquent pas la ligne de vue) == Faux);
		Interrompre si(Joueur exécutant.message_cooldown > Temps total écoulé);
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Message en petit(Joueur exécutant, Chaîne personnalisée(
			"My exchange rates (100 units):\r\n1. Minerals: {0}\r\n2. Vespene Gas: {1}\r\n{2}", Arrondir à l’entier(
			Joueur exécutant.player_prices[0] * 100, Au plus près), Arrondir à l’entier(Joueur exécutant.player_prices[1] * 100,
			Au plus près), Chaîne personnalisée("3. Gold: {0}\r\n4. Lumber: {1}\r\n{2}", Arrondir à l’entier(
			Joueur exécutant.player_prices[2] * 100, Au plus près), Arrondir à l’entier(Joueur exécutant.player_prices[3] * 100,
			Au plus près), Chaîne personnalisée("5. Stone: {0}\r\n6. Food: {1}", Arrondir à l’entier(
			Joueur exécutant.player_prices[4] * 100, Au plus près), Arrondir à l’entier(Joueur exécutant.player_prices[5] * 100,
			Au plus près)))));
	}
}

règle("Player Releases Crouch Button")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.crouch_pressed == Vrai;
		Bouton maintenu enfoncé(Joueur exécutant, Bouton(S’accroupir)) == Faux;
	}

	actions
	{
		Joueur exécutant.crouch_pressed = Faux;
		Interrompre si(Joueur exécutant.crouch_hold_duration == Faux);
		Joueur exécutant.crouch_hold_duration = Faux;
		Interrompre si(Joueur exécutant.message_cooldown > Temps total écoulé);
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Passer si(Joueur exécutant.upgrades[currentTech] < 10, 2);
		Message en petit(Joueur exécutant, Chaîne personnalisée("I have no other tech for you, at the moment."));
		Interrompre;
		Passer(currentTech * 2 + 1);
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("I can offer you a better harvesting beam for {0} credits.",
			Arrondir à l’entier((Joueur exécutant.upgrades[currentTech] + 1 + (
			Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500, Au plus près)));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("How about an upgrade to your dispenser beam for {0} credits?",
			Arrondir à l’entier((Joueur exécutant.upgrades[currentTech] + 1 + (
			Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500, Au plus près)));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("{0} credits and I'll install you a new pair of legs that move faster.",
			Arrondir à l’entier((Joueur exécutant.upgrades[currentTech] + 1 + (
			Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500, Au plus près)));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("An update to your mobile storage capacity for only {0} credits.",
			Arrondir à l’entier((Joueur exécutant.upgrades[currentTech] + 1 + (
			Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500, Au plus près)));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("I can build you a bigger stash for {0} credits.", Arrondir à l’entier((
			Joueur exécutant.upgrades[currentTech] + 1 + (Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500,
			Au plus près)));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("I can offer you better camouflage, but it'll cost you {0} credits.",
			Arrondir à l’entier((Joueur exécutant.upgrades[currentTech] + 1 + (
			Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500, Au plus près)));
		Interrompre;
	}
}

règle("Purchase Tech")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.crouch_hold_duration == Vrai;
		Joueur exécutant.crouch_hold_duration <= Temps total écoulé + -1;
	}

	actions
	{
		Joueur exécutant.crouch_hold_duration = Faux;
		Interrompre si(Distance entre(Joueur exécutant, techPos) > 3);
		Interrompre si(Joueur exécutant.upgrades[currentTech] >= 10);
		temp_1 = Arrondir à l’entier((Joueur exécutant.upgrades[currentTech] + 1 + (
			Joueur exécutant.upgrades[currentTech] + 1) ^ 2) * 2.500, Au plus près);
		Passer si(Joueur exécutant.credits >= temp_1, 3);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Not enough credits."));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Interrompre;
		Joueur exécutant.credits -= temp_1;
		Joueur exécutant.upgrades[currentTech] += 1;
		Joueur exécutant.update_stats_command = Vrai;
		Jouer un effet(Joueur exécutant, Son d’explosion d’amélioration, Couleur(Blanc), Joueur exécutant, 50);
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Passer(currentTech * 2 + 1);
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Harvesting beam upgraded to level {0}!",
			Joueur exécutant.upgrades[0] + 1));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Dispenser beam upgraded to level {0}!",
			Joueur exécutant.upgrades[1] + 1));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Legs upgraded to level {0}!", Joueur exécutant.upgrades[2] + 1));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Carrying capacity upgraded to level {0}!",
			Joueur exécutant.upgrades[3] + 1));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Stash capacity upgraded to level {0}!",
			Joueur exécutant.upgrades[4] + 1));
		Interrompre;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Camouflage upgraded to level {0}!", Joueur exécutant.upgrades[5] + 1));
	}
}

règle("Acknowledge: Show Tech Levels")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Communication(Joueur exécutant, Bien reçu) == Vrai;
		Joueur exécutant.message_cooldown <= Temps total écoulé;
	}

	actions
	{
		Message en petit(Joueur exécutant, Chaîne personnalisée("Harvesting Beam: {0}\r\nDispenser Beam: {1}\r\n{2}",
			Joueur exécutant.upgrades[0] + 1, Joueur exécutant.upgrades[1] + 1, Chaîne personnalisée(
			"Legs: {0}\r\nCarrying Capacity: {1}\r\n{2}", Joueur exécutant.upgrades[2] + 1, Joueur exécutant.upgrades[3] + 1,
			Chaîne personnalisée("Stash Capacity: {0}\r\nCamouflage: {1}", Joueur exécutant.upgrades[4] + 1,
			Joueur exécutant.upgrades[5] + 1))));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
	}
}

règle("Update Seconds Timer")
{
	évènement
	{
		Toute la partie - Tout le monde;
	}

	conditions
	{
		next_second == Vrai;
		next_second <= Temps total écoulé;
	}

	actions
	{
		next_second = Temps total écoulé + 1;
		seconds_left -= 1;
		Interrompre si(seconds_left > 0);
		seconds_left = Nombre entier aléatoire(90, 210);
	}
}

règle("New Phase")
{
	évènement
	{
		Toute la partie - Tout le monde;
	}

	conditions
	{
		seconds_left > 10;
	}

	actions
	{
		Attente(0.250, Ignorer la condition);
		random_value = Nombre entier aléatoire(0, Dernier(rarity_pick_list) + Dernier(rarity_index) + -1);
		overseer_resource = Premier de(Tableau filtré(rarity_pick_list, Élément de tableau actuel >= random_value));
		overseer_resource = Index de la valeur de tableau(rarity_pick_list, overseer_resource);
		Boucle si(overseer_resource == previous_resource || rarity_index[overseer_resource + -1] <= 5);
		previous_resource = overseer_resource;
		rarity_index[0] += overseer_resource != 1;
		rarity_index[1] += overseer_resource != 2;
		rarity_index[2] += overseer_resource != 3;
		rarity_index[3] += overseer_resource != 4;
		rarity_index[4] += overseer_resource != 5;
		rarity_index[5] += overseer_resource != 6;
		rarity_index[overseer_resource + -1] -= 5;
		rarity_pick_list[1] = rarity_index[0];
		rarity_pick_list[2] = rarity_pick_list[1] + rarity_index[1];
		rarity_pick_list[3] = rarity_pick_list[2] + rarity_index[2];
		rarity_pick_list[4] = rarity_pick_list[3] + rarity_index[3];
		rarity_pick_list[5] = rarity_pick_list[4] + rarity_index[4];
		rarity_pick_list[6] = rarity_pick_list[5] + rarity_index[5];
		techPos = zero_vector;
		black_marketeer_position = zero_vector;
		currentTech = Valeur aléatoire dans le tableau(Supprimer du tableau(Section de tableau(numbers_0_11, 0, 6),
			currentTech));
		update_NPC_positions_command = 1;
		default_prices[0] = (10 + 0.714 * rarity_index[0]) * Nombre réel aléatoire(0.008, 0.012);
		default_prices[1] = (10 + 0.714 * rarity_index[1]) * Nombre réel aléatoire(0.008, 0.012);
		default_prices[2] = (10 + 0.714 * rarity_index[2]) * Nombre réel aléatoire(0.008, 0.012);
		default_prices[3] = (10 + 0.714 * rarity_index[3]) * Nombre réel aléatoire(0.008, 0.012);
		default_prices[4] = (10 + 0.714 * rarity_index[4]) * Nombre réel aléatoire(0.008, 0.012);
		default_prices[5] = (10 + 0.714 * rarity_index[5]) * Nombre réel aléatoire(0.008, 0.012);
		default_prices[overseer_resource + -1] = (44.800 + 3.200 * rarity_index[overseer_resource + -1])
			* Nombre réel aléatoire(0.008, 0.012);
		default_prices[6] = (56 + 4 * rarity_index[overseer_resource + -1]) * Nombre réel aléatoire(0.008, 0.012);
		Tous les joueurs(Équipe 1).get_prices_command = 2;
		Attente(1, Ignorer la condition);
		Passer((overseer_resource + -1) * 2 + 1);
		Interrompre;
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("The Overseer Requires Minerals"));
		Passer(1);
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("The Overseer Needs Vespene Gas"));
		Passer(1);
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("The Overseer Demands Gold"));
		Passer(1);
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("The Overseer Calls For Lumber"));
		Passer(1);
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("The Overseer Lacks Stone"));
		Passer(1);
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("The Overseer Wants Food"));
		Interrompre si(Temps total écoulé < 3390);
		Attente(3, Ignorer la condition);
		Passer si(last_round == Vrai, 3);
		Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("Last Round"));
		last_round = Vrai;
		Interrompre;
		Déclarer la victoire d’une équipe(Équipe 1);
	}
}

règle("Get New Positions for Black Marketeer and Tech Guy")
{
	évènement
	{
		Toute la partie - Tout le monde;
	}

	conditions
	{
		update_NPC_positions_command == Vrai;
	}

	actions
	{
		Attente(0.250, Ignorer la condition);
		random_value = Nombre réel aléatoire(5.205, 72);
		random_value = 3 + (0.028 * random_value ^ 3 + -3.008 * random_value ^ 2 + 108 * random_value)
			/ 72 + 0.500 * random_value;
		temp_1 = spawn_center + Direction depuis des angles(Nombre réel aléatoire(0, 359.999), 0) * random_value;
		temp_2 = Position d’impact du rayon émis(temp_1, temp_1 + Vecteur(0, -10, 0), Non applicable, Non applicable,
			Faux);
		Boucle si(Distance entre(temp_1, temp_2) <= 0.250);
		temp_2 = Position la plus proche en marchant(temp_2);
		Boucle si(Vrai pour n’importe qui(Supprimer du tableau(stash_positions, 0), Distance entre(Élément de tableau actuel,
			temp_2) < 8));
		Boucle si(Vrai pour n’importe qui(Supprimer du tableau(resourcePos, zero_vector), Distance entre(
			Élément de tableau actuel, temp_2) < 5));
		Boucle si(Distance entre(temp_2, Vecteur(7.940, 26.980, 195.610)) <= 120 || Distance entre(temp_2, Vecteur(86.150,
			23.600, 113.380)) <= 120);
		Boucle si(Dans la ligne de vue(temp_2 + Haut, temp_2 + Vecteur(1, 1, 0),
			Les barrières ne bloquent pas la ligne de vue) == Faux || Dans la ligne de vue(temp_2 + Haut, temp_2 + Vecteur(
			-1, 1, 0), Les barrières ne bloquent pas la ligne de vue) == Faux || Dans la ligne de vue(temp_2 + Haut,
			temp_2 + Vecteur(0, 1, 1), Les barrières ne bloquent pas la ligne de vue) == Faux || Dans la ligne de vue(
			temp_2 + Haut, temp_2 + Vecteur(0, 1, -1), Les barrières ne bloquent pas la ligne de vue) == Faux);
		Boucle si(Distance entre(temp_2, Vecteur(164.030, 4.180, 268.100)) <= 3);
		Passer si(update_NPC_positions_command >= 2, 3);
		techPos = temp_2;
		update_NPC_positions_command = 2;
		Boucle;
		Boucle si(Distance entre(temp_2, techPos) <= 6.500);
		black_marketeer_position = temp_2;
		update_NPC_positions_command = Faux;
	}
}

règle("Tech Guy Spawned")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Chacal;
	}

	conditions
	{
		Apparition(Joueur exécutant) == Vrai;
	}

	actions
	{
		Désactiver la réapparition prédéfinie par le mode de jeu(Joueur exécutant);
		Regarder vers(Joueur exécutant, Direction(Joueur exécutant, Joueur exécutant.NPC_facing_target), 100, Au monde,
			Direction et Taux de rotation);
		Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("{0} Technician", Chaîne d’icône(Boulon)), Joueur exécutant,
			1.250, Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
	}
}

règle("Black Marketeer Spawned")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Torbjörn;
	}

	conditions
	{
		Apparition(Joueur exécutant) == Vrai;
	}

	actions
	{
		Désactiver la réapparition prédéfinie par le mode de jeu(Joueur exécutant);
		Regarder vers(Joueur exécutant, Direction(Joueur exécutant, Joueur exécutant.NPC_facing_target), 100, Au monde,
			Direction et Taux de rotation);
		Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("{0} Black Marketeer", Chaîne d’icône(Crâne)),
			Joueur exécutant, 1.250, Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc),
			Visibilité par défaut);
	}
}

règle("Tech Guy: Facing Target")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Chacal;
	}

	actions
	{
		Joueur exécutant.NPC_facing_target = Premier de(Tableau trié(Tableau filtré(Tous les joueurs(Équipe 1), Dans la ligne de vue(
			Position des yeux(Joueur exécutant), Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue)),
			Distance entre(Élément de tableau actuel, Joueur exécutant)));
		Passer si(Contenu du tableau(Tous les joueurs(Équipe 1), Joueur exécutant.NPC_facing_target), 1);
		Joueur exécutant.NPC_facing_target = Premier de(Tableau trié(Tous les joueurs(Équipe 1), Distance entre(Élément de tableau actuel,
			Joueur exécutant)));
		Attente(1, Ignorer la condition);
		Boucle;
	}
}

règle("Black Marketeer: Facing Target")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Torbjörn;
	}

	actions
	{
		Joueur exécutant.NPC_facing_target = Premier de(Tableau trié(Tableau filtré(Tous les joueurs(Équipe 1), Dans la ligne de vue(
			Position des yeux(Joueur exécutant), Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue)),
			Distance entre(Élément de tableau actuel, Joueur exécutant)));
		Passer si(Contenu du tableau(Tous les joueurs(Équipe 1), Joueur exécutant.NPC_facing_target), 1);
		Joueur exécutant.NPC_facing_target = Premier de(Tableau trié(Tous les joueurs(Équipe 1), Distance entre(Élément de tableau actuel,
			Joueur exécutant)));
		Attente(1, Ignorer la condition);
		Boucle;
	}
}

règle("Teleport Tech Guy")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Chacal;
	}

	conditions
	{
		Points de vie(Joueur exécutant) == Vrai;
		Joueur exécutant.AI_cooldown <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.AI_cooldown = Temps total écoulé + 0.250;
		Interrompre si(Distance entre(Vecteur(Composante X de(Position de(Joueur exécutant)), 0, Composante Z de(Position de(
			Joueur exécutant))), Vecteur(Composante X de(techPos), 0, Composante Z de(techPos))) <= 1);
		Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), Position de(Joueur exécutant) + Haut, 1);
		Téléportation(Joueur exécutant, techPos);
		Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), techPos + Haut, 1);
	}
}

règle("Teleport Black Marketeer")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Torbjörn;
	}

	conditions
	{
		Points de vie(Joueur exécutant) == Vrai;
		Joueur exécutant.AI_cooldown <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.AI_cooldown = Temps total écoulé + 0.250;
		Interrompre si(Distance entre(Vecteur(Composante X de(Position de(Joueur exécutant)), 0, Composante Z de(Position de(
			Joueur exécutant))), Vecteur(Composante X de(black_marketeer_position), 0, Composante Z de(
			black_marketeer_position))) <= 1);
		Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), Position de(Joueur exécutant) + Haut, 1);
		Téléportation(Joueur exécutant, black_marketeer_position);
		Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), black_marketeer_position + Haut, 1);
	}
}

règle("Update Player Stats")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.update_stats_command == Vrai;
	}

	actions
	{
		Joueur exécutant.update_stats_command = Faux;
		Définir la vitesse de déplacement(Joueur exécutant, (100 + Joueur exécutant.upgrades[2] * 10) * (1 + (
			Joueur exécutant.sprint_cooldown > Temps total écoulé + 12.500) * 5 + Joueur exécutant.carrying_stash * -0.300));
		Joueur exécutant.harvest_length = 12.500 + Joueur exécutant.upgrades[0] * 1.250;
		Joueur exécutant.dispense_length = 12.500 + Joueur exécutant.upgrades[1] * 1.250;
		Joueur exécutant.harvest_power = 0.500 + Joueur exécutant.upgrades[0] * 0.100;
		Joueur exécutant.dispense_power = 0.500 + Joueur exécutant.upgrades[1] * 0.100;
		Joueur exécutant.carry_limit = 30 + Joueur exécutant.upgrades[3] * 3;
		Joueur exécutant.stash_limit = 100 + Joueur exécutant.upgrades[4] * 10;
	}
}

règle("Update Player Prices And Add Interest")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.get_prices_command == Vrai;
	}

	actions
	{
		temp_1 = 1 + -0.010 * 0.250 * Joueur exécutant.loyalty_rank * Valeur absolue(Joueur exécutant.loyalty_rank);
		Joueur exécutant.player_prices[0] = default_prices[0] * temp_1;
		Joueur exécutant.player_prices[1] = default_prices[1] * temp_1;
		Joueur exécutant.player_prices[2] = default_prices[2] * temp_1;
		Joueur exécutant.player_prices[3] = default_prices[3] * temp_1;
		Joueur exécutant.player_prices[4] = default_prices[4] * temp_1;
		Joueur exécutant.player_prices[5] = default_prices[5] * temp_1;
		Joueur exécutant.player_prices[6] = default_prices[6] * (1 + 0.010 * 0.250 * Joueur exécutant.loyalty_rank * Valeur absolue(
			Joueur exécutant.loyalty_rank));
		Passer si(Joueur exécutant.get_prices_command < 2, 15);
		Joueur exécutant.stash_resources[0] *= 1 + Joueur exécutant.interest_rate;
		Joueur exécutant.stash_resources[1] *= 1 + Joueur exécutant.interest_rate;
		Joueur exécutant.stash_resources[2] *= 1 + Joueur exécutant.interest_rate;
		Joueur exécutant.stash_resources[3] *= 1 + Joueur exécutant.interest_rate;
		Joueur exécutant.stash_resources[4] *= 1 + Joueur exécutant.interest_rate;
		Joueur exécutant.stash_resources[5] *= 1 + Joueur exécutant.interest_rate;
		Joueur exécutant.stash_resources[0] -= (Joueur exécutant.stash_resources[0] > Joueur exécutant.carry_limit) * (
			Joueur exécutant.stash_resources[0] - Joueur exécutant.carry_limit);
		Joueur exécutant.stash_resources[1] -= (Joueur exécutant.stash_resources[1] > Joueur exécutant.carry_limit) * (
			Joueur exécutant.stash_resources[1] - Joueur exécutant.carry_limit);
		Joueur exécutant.stash_resources[2] -= (Joueur exécutant.stash_resources[2] > Joueur exécutant.carry_limit) * (
			Joueur exécutant.stash_resources[2] - Joueur exécutant.carry_limit);
		Joueur exécutant.stash_resources[3] -= (Joueur exécutant.stash_resources[3] > Joueur exécutant.carry_limit) * (
			Joueur exécutant.stash_resources[3] - Joueur exécutant.carry_limit);
		Joueur exécutant.stash_resources[4] -= (Joueur exécutant.stash_resources[4] > Joueur exécutant.carry_limit) * (
			Joueur exécutant.stash_resources[4] - Joueur exécutant.carry_limit);
		Joueur exécutant.stash_resources[5] -= (Joueur exécutant.stash_resources[5] > Joueur exécutant.carry_limit) * (
			Joueur exécutant.stash_resources[5] - Joueur exécutant.carry_limit);
		Passer si(Joueur exécutant.loyalty_rank < 1 || Joueur exécutant.contributed_in_phase >= Joueur exécutant.loyalty_rank, 1);
		Joueur exécutant.loyalty_hidden -= (Joueur exécutant.loyalty_rank - Joueur exécutant.contributed_in_phase)
			* Joueur exécutant.loyalty_rank * 1;
		Joueur exécutant.contributed_in_phase = 0;
		Joueur exécutant.get_prices_command = Faux;
		Joueur exécutant.credits += (
			Joueur exécutant.stash_resources[0] + Joueur exécutant.stash_resources[1] + Joueur exécutant.stash_resources[2] + Joueur exécutant.stash_resources[3] + Joueur exécutant.stash_resources[4] + Joueur exécutant.stash_resources[5])
			* Joueur exécutant.interest_rate;
	}
}

règle("Voiceline Penalty")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Communication par réplique(Joueur exécutant) == Vrai;
		Joueur exécutant.spam_check <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.spam_check = Temps total écoulé + 1;
		Joueur exécutant.spam_counter += 3;
		Interrompre si(Joueur exécutant.spam_counter < 30);
		Message en petit(Joueur exécutant, Chaîne personnalisée("The Overseer does not condone ignominious banter."));
		Joueur exécutant.is_stealing = Vrai;
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
	}
}

règle("AI Spawned")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Orisa;
	}

	conditions
	{
		Apparition(Joueur exécutant) == Vrai;
	}

	actions
	{
		Désactiver la réapparition prédéfinie par le mode de jeu(Joueur exécutant);
		Définir un statut(Joueur exécutant, Non applicable, Invincible, 9999);
		Joueur exécutant.AI_previous_position = Vecteur(45.120, -23.900, 15.140);
		Joueur exécutant.AI_current_angle = Angle horizontal depuis une direction(Regard en direction de(Joueur exécutant));
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Commencer l’accélération directionnelle(Joueur exécutant, Joueur exécutant.AI_move_direction, 0.500, Au monde,
			Remplacer l’accélération existante, Direction et ampleur);
		Regarder vers(Joueur exécutant, Direction(Position des yeux(Joueur exécutant), Joueur exécutant.AI_facing_target + Haut), 360,
			Au monde, Direction et Taux de rotation);
		Joueur exécutant.AI_cooldown = Vrai;
		Joueur exécutant.AI_facing_target = Joueur exécutant + Joueur exécutant.AI_move_direction * 100;
	}
}

règle("AI Movement")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Orisa;
	}

	conditions
	{
		Joueur exécutant.AI_cooldown == Vrai;
		Joueur exécutant.AI_cooldown <= Temps total écoulé;
		Points de vie(Joueur exécutant) == Vrai;
	}

	actions
	{
		Passer si(Distance entre(Joueur exécutant, Vecteur(159.430, 11.530, 263.440)) > 2.250, 3);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Jaune), Position de(Joueur exécutant), 1);
		Téléportation(Joueur exécutant, overseerPos);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Jaune), overseerPos, 1);
		Joueur exécutant.update_facing_target_command = Vrai;
		Passer si(Distance entre(Joueur exécutant.AI_facing_target, Joueur exécutant) <= 5 || Contenu du tableau(Tous les joueurs(
			Équipe 1), Joueur exécutant.AI_facing_target) == Faux, 1);
		Joueur exécutant.AI_move_direction = Direction(Joueur exécutant, Joueur exécutant.AI_facing_target);
		Passer si(Distance entre(Joueur exécutant, Joueur exécutant.AI_previous_position) > 0.100, 3);
		Appuyer sur un bouton(Joueur exécutant, Bouton(Sauter));
		Joueur exécutant.AI_current_angle = Nombre entier aléatoire(0, 359);
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Joueur exécutant.AI_previous_position = Position de(Joueur exécutant);
		Joueur exécutant.AI_cooldown = Temps total écoulé + 0.250;
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += Nombre entier aléatoire(20, 40);
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += -60;
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += 90;
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += -120;
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += 150;
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += -180;
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
		Interrompre si(Composante Y de(Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 2, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 2,
			Non applicable, Non applicable, Faux)) >= Composante Y de(Position de(Joueur exécutant)) + -2.500 && Dans la ligne de vue(
			Joueur exécutant + Haut, Haut + Position d’impact du rayon émis(Joueur exécutant + Vecteur(0, 2.500, 0)
			+ Joueur exécutant.AI_move_direction * 4, Joueur exécutant + Vecteur(0, -10, 0) + Joueur exécutant.AI_move_direction * 4,
			Non applicable, Non applicable, Faux), Les barrières ne bloquent pas la ligne de vue));
		Joueur exécutant.AI_current_angle += -90;
		Joueur exécutant.AI_move_direction = Direction depuis des angles(Joueur exécutant.AI_current_angle, 0);
	}
}

règle("AI Facing Target")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Orisa;
	}

	conditions
	{
		Joueur exécutant.update_facing_target_command == Vrai;
	}

	actions
	{
		Joueur exécutant.update_facing_target_command = Faux;
		Joueur exécutant.AI_facing_target = Premier de(Tableau trié(Tableau filtré(Tous les joueurs en vie(Équipe 1),
			Élément de tableau actuel.is_stealing == Vrai && Dans la ligne de vue(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue)), Distance entre(Élément de tableau actuel,
			Joueur exécutant)));
		Passer si(Contenu du tableau(Tous les joueurs(Équipe 1), Joueur exécutant.AI_facing_target), 1);
		Joueur exécutant.AI_facing_target = Joueur exécutant + Joueur exécutant.AI_move_direction * 100;
	}
}

règle("")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Tout;
	}

	conditions
	{
		Apparition(Joueur exécutant) == Vrai;
		Points de vie(Joueur exécutant) == Faux;
	}

	actions
	{
		Attente(3, Ignorer la condition);
		Passer si(Héros de(Joueur exécutant) != Héros(Chacal) && Héros de(Joueur exécutant) != Héros(Torbjörn), 4);
		Téléportation(Joueur exécutant, zero_vector);
		Attente(0.250, Ignorer la condition);
		Ressusciter(Joueur exécutant);
		Interrompre;
		Téléportation(Joueur exécutant, overseerPos);
		Ressusciter(Joueur exécutant);
		Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Jaune), overseerPos, 1);
	}
}

règle("Player Is Stealing")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Joueur exécutant.is_stealing == Vrai;
		Joueur exécutant.stealing_cooldown <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.stealing_cooldown = Temps total écoulé + 0.250;
		Passer si(Joueur exécutant.spam_counter >= 30, 9);
		Passer si(Joueur exécutant.active_beam_type != 2, 2);
		Joueur exécutant.stealing_from = Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1);
		Passer si(Points de vie(Joueur exécutant.stealing_from) == Vrai && Distance entre(Joueur exécutant, Joueur exécutant.stealing_from)
			<= 50 + Joueur exécutant.upgrades[5] * -4 && Dans le champ de vision(Joueur exécutant.stealing_from, Joueur exécutant, 90)
			&& Dans la ligne de vue(Position des yeux(Joueur exécutant.stealing_from), Joueur exécutant + Haut,
			Les barrières ne bloquent pas la ligne de vue), 2);
		Interrompre si(Vrai pour tous(Joueurs sur le héros(Héros(Orisa), Équipe 2), Points de vie(Élément de tableau actuel)
			== Faux || Dans le champ de vision(Élément de tableau actuel, Joueur exécutant, 90) == Faux || Distance entre(
			Élément de tableau actuel, Joueur exécutant) > 50 + -4 * Joueur exécutant.upgrades[5] || Dans la ligne de vue(
			Position des yeux(Élément de tableau actuel), Joueur exécutant + Haut, Les barrières ne bloquent pas la ligne de vue)
			== Faux));
		Passer si(Joueur exécutant.active_beam_type != 2, 2);
		Message en petit(Tous les joueurs(Équipe 1), Chaîne personnalisée("{0} was caught stealing from {1}'s stash.", Joueur exécutant,
			Joueur exécutant.stealing_from));
		Passer(1);
		Message en petit(Tous les joueurs(Équipe 1), Chaîne personnalisée("{0} was caught selling goods on the black market.",
			Joueur exécutant));
		Joueur exécutant.message_cooldown = Temps total écoulé + 3;
		Joueur exécutant.loyalty_hidden -= Joueur exécutant.stealing_modifier * (20 + (Joueur exécutant.active_beam_type == 2) * 20);
		Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
		Passer si(Joueur exécutant.active_beam_type == Faux, 2);
		Joueur exécutant.who_can_see_harvest_beam = Non applicable;
		Joueur exécutant.who_can_see_dispense_beam = Non applicable;
		Joueur exécutant.active_beam_type = Faux;
		Joueur exécutant.is_stealing = Faux;
		temp_2 = 10 - (Joueur exécutant.loyalty_rank < 0) * Joueur exécutant.loyalty_rank;
		Joueur exécutant.beam_check_cooldown = Temps total écoulé + temp_2;
		Joueur exécutant.stealing_cooldown = Temps total écoulé + temp_2;
		Joueur exécutant.spam_check = Temps total écoulé + temp_2;
		Définir un statut(Joueur exécutant, Non applicable, Renversé, temp_2);
		Interrompre si(Joueur exécutant.loyalty_rank > -11);
		Joueur exécutant.credits *= 1 + 0.100 * (Joueur exécutant.loyalty_rank + 10);
		temp_1 = Joueur exécutant.carry_limit * -0.100 * (Joueur exécutant.loyalty_rank + 10);
		Joueur exécutant.carry_resources[0] -= temp_1;
		Joueur exécutant.carry_resources[1] -= temp_1;
		Joueur exécutant.carry_resources[2] -= temp_1;
		Joueur exécutant.carry_resources[3] -= temp_1;
		Joueur exécutant.carry_resources[4] -= temp_1;
		Joueur exécutant.carry_resources[5] -= temp_1;
		Joueur exécutant.carry_resources[0] += (Joueur exécutant.carry_resources[0] < 0) * (0 - Joueur exécutant.carry_resources[0]);
		Joueur exécutant.carry_resources[1] += (Joueur exécutant.carry_resources[1] < 0) * (0 - Joueur exécutant.carry_resources[1]);
		Joueur exécutant.carry_resources[2] += (Joueur exécutant.carry_resources[2] < 0) * (0 - Joueur exécutant.carry_resources[2]);
		Joueur exécutant.carry_resources[3] += (Joueur exécutant.carry_resources[3] < 0) * (0 - Joueur exécutant.carry_resources[3]);
		Joueur exécutant.carry_resources[4] += (Joueur exécutant.carry_resources[4] < 0) * (0 - Joueur exécutant.carry_resources[4]);
		Joueur exécutant.carry_resources[5] += (Joueur exécutant.carry_resources[5] < 0) * (0 - Joueur exécutant.carry_resources[5]);
		Message en petit(Joueur exécutant, Chaîne personnalisée("The guards took {0}% of your credits and your total carry capacity.",
			Arrondir à l’entier((Joueur exécutant.loyalty_rank + 10) * -10, Au plus près)));
	}
}

règle("Greetings")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 2;
		Tout;
	}

	conditions
	{
		Points de vie(Joueur exécutant) == Vrai;
		Joueur exécutant.greeting_cooldown <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.greeting_cooldown = Temps total écoulé + 2;
		Passer si(Héros de(Joueur exécutant) == Héros(Orisa), 5);
		Passer si(Héros de(Joueur exécutant) == Héros(Torbjörn), 2);
		temp_1 = Tableau filtré(Tous les joueurs en vie(Équipe 1), Distance entre(Joueur exécutant, Élément de tableau actuel)
			<= 10 && Dans la ligne de vue(Position des yeux(Joueur exécutant), Élément de tableau actuel + Haut,
			Les barrières ne bloquent pas la ligne de vue) && Dans le champ de vision(Joueur exécutant, Élément de tableau actuel, 90));
		Passer(3);
		temp_1 = Tableau filtré(Tous les joueurs en vie(Équipe 1), Distance entre(Élément de tableau actuel, Joueur exécutant)
			<= 10 && Élément de tableau actuel.loyalty_rank < 0 && Dans la ligne de vue(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue) && Dans le champ de vision(Joueur exécutant,
			Élément de tableau actuel, 90));
		Passer(1);
		temp_1 = Tableau filtré(Tous les joueurs en vie(Équipe 1), Distance entre(Élément de tableau actuel, Joueur exécutant)
			<= 10 && Élément de tableau actuel.loyalty_rank >= 0 && Dans la ligne de vue(Position des yeux(Joueur exécutant),
			Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue) && Dans le champ de vision(Joueur exécutant,
			Élément de tableau actuel, 90));
		Interrompre si(temp_1 == Tableau vide);
		Joueur exécutant.greeting_cooldown = Temps total écoulé + 25;
		Communiquer(Joueur exécutant, Bonjour);
	}
}

règle("Need Healing: Display Instructions")
{
	évènement
	{
		Toute la partie - Chaque joueur;
		Équipe 1;
		Tout;
	}

	conditions
	{
		Communication(Joueur exécutant, Besoin de soins) == Vrai;
		Joueur exécutant.message_cooldown <= Temps total écoulé;
	}

	actions
	{
		Joueur exécutant.message_cooldown = Temps total écoulé + 49.750;
		Message en petit(Joueur exécutant, Chaîne personnalisée("Press Primary Fire to harvest resoures from a node or your stash."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Use Secondary Fire to dispense resources."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée(
			"Press Ability 2 or Interact to change the setting of your dispenser beam."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Hold Ultimate for 1 second to destroy all resources you carry."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Press Crouch to pick up and to place your stash."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Press Ability 1 to sprint for a short duration."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Press Crouch to talk to NPCs."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Hold Crouch for 1 second to buy an upgrade from the Technician."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Acknowledge will display your current tech levels."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("The Overseer asks us to bring him one specific resource."));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("I guess we better obey?"));
		Attente(4.250, Ignorer la condition);
		Message en petit(Joueur exécutant, Chaîne personnalisée("Good luck!"));
	}
}