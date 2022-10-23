paramètres
{
    principal
    {
        Description: "The Overseer v1.2 (by Delwion#2667): The Overseer demands you bring him resources. Will you become one of his most loyal subordinates, bunker all your resources in your stash, or work as a thief and do shady business on the black market?” (Open-ended resource harvesting game mode for 1-6 players)."
        Nom du mode: "The Overseer"
    }

    salon
    {
        Inversion des équipes après une partie: Non
        Joueurs max. dans Équipe 2.: 0
        Retour au salon: Jamais
        Rotation des cartes: Après une partie
        Spectateurs max.: 6
    }

    modes
    {
        Échauffement
        {
            cartes activées
            {
                Oasis
            }
        }

        Général
        {
            Apparition des kits de soins: Désactivé
            Barres de vie adverses: Désactivé
            Changement de héros: Désactivé
            Début de la partie: Immédiatement
            Limite de héros: Désactivé
        }
    }

    héros
    {
        Général
        {
            Coup en mêlée: Désactivé

            héros activés
            {
                Bastion
            }
        }
    }
}

variables
{
    globale:
        0: overseer_resource
        1: spawn_center
        2: temp_1
        3: temp_2
        4: temp_3
        5: stash_positions
        6: total_resources
        7: resource_cooldown
        8: resource_amounts
        9: resource_despawn_times
        10: previous_resource
        11: rarity_index
        12: rarity_pick_list
        13: next_second
        14: resource_positions
        15: numbers_0_11
        16: random_value
        17: despawn_check
        18: temp_effect_position
        19: zero_vector
        20: overseer_position
        21: black_marketeer_player
        22: tech_for_sale
        23: update_NPC_positions_command
        24: tech_guy_player
        25: black_marketeer_position
        26: tech_guy_position
        27: default_prices
        28: last_round
        29: seconds_left

    de joueur:
        0: credits
        1: stash_position
        2: stash_resources
        3: stash_limit
        4: carry_resources
        5: carry_limit
        6: beam_check_cooldown
        7: beam_target
        8: who_can_see_harvest_beam
        9: active_beam_type
        10: primary_blocked
        11: harvest_power
        12: dispense_power
        13: harvest_length
        14: dispense_length
        15: update_stats_command
        16: upgrades
        17: beam_target_index
        18: resource_type
        19: who_can_see_stash_icon
        20: message_cooldown
        21: temp_effect_position
        22: sound_position
        23: secondary_blocked
        24: carrying_stash
        25: is_stealing
        26: who_can_see_dispense_beam
        27: stash_update_cooldown
        28: check_primary_on_stash
        29: previous_stash_position
        30: loyalty_hidden
        31: loyalty_rank
        32: check_secondary_delivery
        33: ult_button_duration
        34: crouch_pressed
        35: crouch_cooldown
        36: player_prices
        37: NPC_facing_target
        38: get_prices_command
        39: interest_rate
        40: crouch_hold_duration
        41: sprint_cooldown
        42: previous_loyalty_rank
        43: stealing_modifier
        44: contributed_in_phase
        45: spam_counter
        46: AI_cooldown
        47: AI_move_direction
        48: AI_current_angle
        49: AI_previous_position
        50: AI_facing_target
        51: update_facing_target_command
        52: stealing_cooldown
        53: spam_check
        54: greeting_cooldown
        55: stealing_from
}

règle("#Levelstart - Main Values")
{
    évènement
    {
        Toute la partie - Tout le monde;
    }

    actions
    {
        Désactiver l’enregistrement du contrôleur;
        Désactiver l’accomplissement prédéfini par le mode de jeu;
        Définir le temps de jeu(3600);
        Global.spawn_center = Vecteur(146.990, 6, 251.050);
        Global.zero_vector = Vecteur(139, 5.500, -283);
        Global.resource_positions[0] = Global.zero_vector;
        Global.resource_positions[1] = Global.zero_vector;
        Global.resource_positions[2] = Global.zero_vector;
        Global.resource_positions[3] = Global.zero_vector;
        Global.resource_positions[4] = Global.zero_vector;
        Global.resource_positions[5] = Global.zero_vector;
        Global.resource_positions[6] = Global.zero_vector;
        Global.resource_positions[7] = Global.zero_vector;
        Global.resource_positions[8] = Global.zero_vector;
        Global.resource_positions[9] = Global.zero_vector;
        Global.resource_positions[10] = Global.zero_vector;
        Global.resource_positions[11] = Global.zero_vector;
        Global.numbers_0_11[1] = 1;
        Global.numbers_0_11[2] = 2;
        Global.numbers_0_11[3] = 3;
        Global.numbers_0_11[4] = 4;
        Global.numbers_0_11[5] = 5;
        Global.numbers_0_11[6] = 6;
        Global.numbers_0_11[7] = 7;
        Global.numbers_0_11[8] = 8;
        Global.numbers_0_11[9] = 9;
        Global.numbers_0_11[10] = 10;
        Global.numbers_0_11[11] = 11;
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Bleu ciel), Global.resource_positions[0] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Bleu ciel), Global.resource_positions[1] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Vert), Global.resource_positions[2] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Vert), Global.resource_positions[3] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Orange), Global.resource_positions[4] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Orange), Global.resource_positions[5] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Citron vert), Global.resource_positions[6] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Citron vert), Global.resource_positions[7] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Blanc), Global.resource_positions[8] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Blanc), Global.resource_positions[9] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Rouge), Global.resource_positions[10] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Orbe, Couleur(Rouge), Global.resource_positions[11] + Haut, 0.500,
            Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Bleu ciel), Global.resource_positions[0] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Bleu ciel), Global.resource_positions[1] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Vert), Global.resource_positions[2] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Vert), Global.resource_positions[3] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Orange), Global.resource_positions[4] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Orange), Global.resource_positions[5] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Citron vert), Global.resource_positions[6] + Vecteur(0, -15,
            0), 0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Citron vert), Global.resource_positions[7] + Vecteur(0, -15,
            0), 0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Blanc), Global.resource_positions[8] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Blanc), Global.resource_positions[9] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Rouge), Global.resource_positions[10] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer un effet(Tous les joueurs(Équipe 1), Puits de lumière, Couleur(Rouge), Global.resource_positions[11] + Vecteur(0, -15, 0),
            0.600, Visible pour Position et Rayon);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Minerals: {0}", Arrondir à l’entier(
            Global.resource_amounts[0], Au-dessus)), Global.resource_positions[0] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Minerals: {0}", Arrondir à l’entier(
            Global.resource_amounts[1], Au-dessus)), Global.resource_positions[1] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Vespene Gas: {0}", Arrondir à l’entier(
            Global.resource_amounts[2], Au-dessus)), Global.resource_positions[2] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Vespene Gas: {0}", Arrondir à l’entier(
            Global.resource_amounts[3], Au-dessus)), Global.resource_positions[3] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Gold: {0}", Arrondir à l’entier(Global.resource_amounts[4],
            Au-dessus)), Global.resource_positions[4] + Vecteur(0, 1.500, 0), 1.250, Masquer derrière les surfaces,
            Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Gold: {0}", Arrondir à l’entier(Global.resource_amounts[5],
            Au-dessus)), Global.resource_positions[5] + Vecteur(0, 1.500, 0), 1.250, Masquer derrière les surfaces,
            Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Lumber: {0}", Arrondir à l’entier(
            Global.resource_amounts[6], Au-dessus)), Global.resource_positions[6] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Lumber: {0}", Arrondir à l’entier(
            Global.resource_amounts[7], Au-dessus)), Global.resource_positions[7] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Stone: {0}", Arrondir à l’entier(
            Global.resource_amounts[8], Au-dessus)), Global.resource_positions[8] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Stone: {0}", Arrondir à l’entier(
            Global.resource_amounts[9], Au-dessus)), Global.resource_positions[9] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Food: {0}", Arrondir à l’entier(
            Global.resource_amounts[10], Au-dessus)), Global.resource_positions[10] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("Food: {0}", Arrondir à l’entier(
            Global.resource_amounts[11], Au-dessus)), Global.resource_positions[11] + Vecteur(0, 1.500, 0), 1.250,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Global.overseer_position = Vecteur(143.490, 4.150, 247.490);
        Créer un effet(Tous les joueurs(Équipe 1), Sphère, Couleur(Jaune), Global.overseer_position + Haut, 3, Visible pour);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("{0} The Overseer", Chaîne d’icône(Œil)),
            Global.overseer_position + Haut, 1.750, Masquer derrière les surfaces, Visible pour et Chaîne de texte, Couleur(Jaune),
            Visibilité par défaut);
        Global.rarity_index[0] = 16;
        Global.rarity_index[1] = 16;
        Global.rarity_index[2] = 16;
        Global.rarity_index[3] = 16;
        Global.rarity_index[4] = 16;
        Global.rarity_index[5] = 16;
        Global.rarity_pick_list[0] = -1;
        Global.rarity_pick_list[1] = 16;
        Global.rarity_pick_list[2] = 32;
        Global.rarity_pick_list[3] = 48;
        Global.rarity_pick_list[4] = 64;
        Global.rarity_pick_list[5] = 80;
        Global.rarity_pick_list[6] = 96;
        Global.tech_for_sale = -1;
        Global.black_marketeer_position = Global.zero_vector;
        Global.tech_guy_position = Global.zero_vector;
        Créer une I.A.(Héros(Chacal), Équipe 2, 0, Global.zero_vector, Non applicable);
        Global.tech_guy_player = Joueurs sur le héros(Héros(Chacal), Équipe 2);
        Créer une I.A.(Héros(Torbjörn), Équipe 2, 1, Global.zero_vector, Non applicable);
        Global.black_marketeer_player = Joueurs sur le héros(Héros(Torbjörn), Équipe 2);
        Créer une I.A.(Héros(Orisa), Équipe 2, 2, Global.overseer_position, Direction depuis des angles(Nombre entier aléatoire(0, 359),
            0));
        Créer une I.A.(Héros(Orisa), Équipe 2, 3, Global.overseer_position, Direction depuis des angles(Nombre entier aléatoire(0, 359),
            0));
        Créer une I.A.(Héros(Orisa), Équipe 2, 4, Global.overseer_position, Direction depuis des angles(Nombre entier aléatoire(0, 359),
            0));
        Créer une I.A.(Héros(Orisa), Équipe 2, 5, Global.overseer_position, Direction depuis des angles(Nombre entier aléatoire(0, 359),
            0));
    }
}

règle("#Get Player Spawn Position")
{
    évènement
    {
        Toute la partie - Chaque joueur;
        Équipe 1;
        Tout;
    }

    actions
    {
        Attente(0.250, Ignorer la condition);
        Global.random_value = Nombre réel aléatoire(5.205, 72);
        Global.random_value = 3 + (0.028 * Global.random_value ^ 3 + -3.008 * Global.random_value ^ 2 + 108 * Global.random_value)
            / 72 + 0.500 * Global.random_value;
        Global.temp_1 = Global.spawn_center + Direction depuis des angles(Nombre réel aléatoire(0, 359.999), 0) * Global.random_value;
        Global.temp_2 = Position d’impact du rayon émis(Global.temp_1, Global.temp_1 + Vecteur(0, -10, 0), Non applicable, Non applicable,
            Faux);
        Boucle si(Distance entre(Global.temp_1, Global.temp_2) <= 0.250);
        Global.temp_2 = Position la plus proche en marchant(Global.temp_2);
        Boucle si(Vrai pour n’importe qui(Supprimer du tableau(Global.stash_positions, 0), Distance entre(Élément de tableau actuel,
            Global.temp_2) < 8));
        Boucle si(Vrai pour n’importe qui(Supprimer du tableau(Global.resource_positions, Global.zero_vector), Distance entre(
            Élément de tableau actuel, Global.temp_2) < 5));
        Boucle si(Distance entre(Global.temp_2, Global.black_marketeer_position) <= 6.500 || Distance entre(Global.temp_2,
            Global.tech_guy_position) <= 6.500);
        Boucle si(Distance entre(Global.temp_2, Vecteur(7.940, 26.980, 195.610)) <= 120 || Distance entre(Global.temp_2, Vecteur(86.150,
            23.600, 113.380)) <= 120);
        Joueur exécutant.stash_position = Global.temp_2;
        Joueur exécutant.previous_stash_position = Joueur exécutant.stash_position;
        Global.stash_positions[Emplacement de(Joueur exécutant)] = Joueur exécutant.stash_position;
        Joueur exécutant.interest_rate = 0.001 * 0.020 * Distance entre(Joueur exécutant.stash_position, Global.overseer_position)
            * Distance entre(Joueur exécutant.stash_position, Global.overseer_position);
        Définir l’activation du tir principal(Joueur exécutant, Faux);
        Définir l’activation du tir secondaire(Joueur exécutant, Faux);
        Interdire le bouton(Joueur exécutant, Bouton(Capacité 1));
        Définir l’activation de la capacité 2(Joueur exécutant, Faux);
        Définir l’activation de la capacité ultime(Joueur exécutant, Faux);
        Joueur exécutant.stealing_modifier = 1;
    }
}

règle("@Player Spawns")
{
    évènement
    {
        Toute la partie - Chaque joueur;
        Équipe 1;
        Tout;
    }

    conditions
    {
        Apparition(Joueur exécutant) == Vrai;
        Joueur exécutant.stash_position != 0;
    }

    actions
    {
        Désactiver la réapparition prédéfinie par le mode de jeu(Joueur exécutant);
        Définir un statut(Joueur exécutant, Non applicable, Invincible, 3);
        Téléportation(Joueur exécutant, Joueur exécutant.stash_position);
        Créer du texte en jeu(Tous les joueurs(Équipe 1), Chaîne personnalisée("{0}'s Stash\r\n1. Minerals: {1}/{2}", Joueur exécutant,
            Arrondir à l’entier(Joueur exécutant.stash_resources[0], En dessous), Chaîne personnalisée("{0}\r\n2. Vespene Gas: {1}/{2}",
            Joueur exécutant.stash_limit, Arrondir à l’entier(Joueur exécutant.stash_resources[1], En dessous), Chaîne personnalisée(
            "{0}\r\n3. Gold: {1}/{2}", Joueur exécutant.stash_limit, Arrondir à l’entier(Joueur exécutant.stash_resources[2], En dessous),
            Chaîne personnalisée("{0}\r\n4. Lumber: {1}/{2}", Joueur exécutant.stash_limit, Arrondir à l’entier(
            Joueur exécutant.stash_resources[3], En dessous), Chaîne personnalisée("{0}\r\n5. Stone: {1}/{2}",
            Joueur exécutant.stash_limit, Arrondir à l’entier(Joueur exécutant.stash_resources[4], En dessous), Chaîne personnalisée(
            "{0}\r\n6. Food: {1}/{2}", Joueur exécutant.stash_limit, Arrondir à l’entier(Joueur exécutant.stash_resources[5], En dessous),
            Joueur exécutant.stash_limit)))))), Joueur exécutant.stash_position + Vecteur(0, 1.500, 0), 1.500,
            Masquer derrière les surfaces, Visible pour Position et Chaîne de texte, Couleur(Blanc), Visibilité par défaut);
        Créer du texte d’interface(Joueur exécutant, Non applicable, Non applicable, Chaîne personnalisée(
            "Carrying:\r\n1. Minerals: {0}/{1}\r\n{2}", Arrondir à l’entier(Joueur exécutant.carry_resources[0], En dessous),
            Joueur exécutant.carry_limit, Chaîne personnalisée("2. Vespene Gas: {0}/{1}\r\n{2}", Arrondir à l’entier(
            Joueur exécutant.carry_resources[1], En dessous), Joueur exécutant.carry_limit, Chaîne personnalisée("3. Gold: {0}/{1}\r\n{2}",
            Arrondir à l’entier(Joueur exécutant.carry_resources[2], En dessous), Joueur exécutant.carry_limit, Chaîne personnalisée(
            "4. Lumber: {0}/{1}\r\n{2}", Arrondir à l’entier(Joueur exécutant.carry_resources[3], En dessous),
            Joueur exécutant.carry_limit, Chaîne personnalisée("5. Stone: {0}/{1}\r\n{2}", Arrondir à l’entier(
            Joueur exécutant.carry_resources[4], En dessous), Joueur exécutant.carry_limit, Chaîne personnalisée("6. Food: {0}/{1}",
            Arrondir à l’entier(Joueur exécutant.carry_resources[5], En dessous), Joueur exécutant.carry_limit)))))), Gauche, 1, Couleur(
            Blanc), Couleur(Blanc), Couleur(Blanc), Chaîne de texte, Visibilité par défaut);
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
        Créer du texte d’interface(Joueur exécutant, Chaîne personnalisée("Overseer resource: {0}", Global.previous_resource),
            Chaîne personnalisée("Reward (100 units): {0} credits", Arrondir à l’entier(Joueur exécutant.player_prices[6] * 100,
            Au plus près)), Chaîne personnalisée("Seconds left: {0}", Global.seconds_left), Haut, -2, Couleur(Blanc), Couleur(Blanc),
            Couleur(Blanc), Chaîne de texte, Visibilité par défaut);
        Créer du texte d’interface(Joueur exécutant, Non applicable, Non applicable, Chaîne personnalisée(
            "Credits: {1}\r\nLoyalty Rank: {0}", Joueur exécutant.loyalty_rank, Arrondir à l’entier(Joueur exécutant.credits, En dessous)),
            Droite, -1, Couleur(Blanc), Couleur(Blanc), Couleur(Blanc), Chaîne de texte, Visibilité par défaut);
        Joueur exécutant.stash_update_cooldown = Vrai;
        Passer si(Global.next_second > 0, 2);
        Global.seconds_left = 10;
        Global.next_second = Temps total écoulé + 1;
        Attente(3, Ignorer la condition);
        Message en petit(Joueur exécutant, Chaîne personnalisée("Stash Interest Rate: {0}% per phase",
            Joueur exécutant.interest_rate * 100));
        Interrompre si(Global.seconds_left <= 10);
        Passer((Global.overseer_resource + -1) * 2 + 1);
        Interrompre;
        Message en grand(Joueur exécutant, Chaîne personnalisée("The Overseer Requires Minerals"));
        Passer(1);
        Message en grand(Joueur exécutant, Chaîne personnalisée("The Overseer Needs Vespene Gas"));
        Passer(1);
        Message en grand(Joueur exécutant, Chaîne personnalisée("The Overseer Demands Gold"));
        Passer(1);
        Message en grand(Joueur exécutant, Chaîne personnalisée("The Overseer Calls For Lumber"));
        Passer(1);
        Message en grand(Joueur exécutant, Chaîne personnalisée("The Overseer Lacks Stone"));
        Passer(1);
        Message en grand(Joueur exécutant, Chaîne personnalisée("The Overseer Wants Food"));
        Interrompre si(Global.last_round == Faux);
        Attente(3, Ignorer la condition);
        Message en grand(Joueur exécutant, Chaîne personnalisée("Last Round"));
    }
}

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
        Global.temp_1 = Premier de(Tableau trié(Tableau filtré(Supprimer du tableau(Global.resource_positions, Global.zero_vector),
            Dans le champ de vision(Joueur exécutant, Élément de tableau actuel, 90) && Distance entre(Élément de tableau actuel,
            Joueur exécutant) <= Joueur exécutant.harvest_length && Dans la ligne de vue(Position des yeux(Joueur exécutant),
            Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(
            Joueur exécutant), Élément de tableau actuel + Haut) + -0.500), Les barrières ne bloquent pas la ligne de vue)
            && Distance entre(Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(
            Élément de tableau actuel + Vecteur(0, 1, 0) - Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)),
            Élément de tableau actuel + Vecteur(0, 1, 0)) <= 0.625), Angle entre deux vecteurs(Regard en direction de(Joueur exécutant),
            Direction(Position des yeux(Joueur exécutant), Élément de tableau actuel + Vecteur(0, 1, 0)))));
        Passer(1);
        Global.temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
            <= Joueur exécutant.harvest_length + 0.250);
        Passer si(Global.temp_1 == Vrai, 7);
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.who_can_see_harvest_beam = Non applicable;
        Passer si(Joueur exécutant.active_beam_type == Vrai, 1);
        Joueur exécutant.check_primary_on_stash = Vrai;
        Joueur exécutant.active_beam_type = Faux;
        Joueur exécutant.primary_blocked = Vrai;
        Interrompre;
        Global.resource_despawn_times[Joueur exécutant.beam_target_index] = Temps total écoulé + 60;
        Passer si(Joueur exécutant.active_beam_type != 1, 36);
        Global.temp_3 = Joueur exécutant.harvest_power;
        Passer si(
            Joueur exécutant.harvest_power <= Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type],
            4);
        Global.temp_3 = Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
        Passer si(
            Joueur exécutant.carry_resources[Joueur exécutant.resource_type] < Joueur exécutant.carry_limit || Joueur exécutant.message_cooldown > Temps total écoulé,
            2);
        Message en petit(Joueur exécutant, Chaîne personnalisée("Carrying capacity reached"));
        Joueur exécutant.message_cooldown = Temps total écoulé + 3;
        Passer si(Global.temp_3 < Global.resource_amounts[Joueur exécutant.beam_target_index], 25);
        Global.temp_2 = Global.resource_amounts[Joueur exécutant.beam_target_index];
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.temp_effect_position = Global.resource_positions[Joueur exécutant.beam_target_index];
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
        Global.resource_positions[Joueur exécutant.beam_target_index] = Global.zero_vector;
        Global.resource_amounts[Joueur exécutant.beam_target_index] = Faux;
        Global.resource_despawn_times[Global.temp_2] = 0;
        Global.total_resources -= 1;
        Joueur exécutant.who_can_see_harvest_beam = Non applicable;
        Joueur exécutant.active_beam_type = 1;
        Joueur exécutant.primary_blocked = Vrai;
        Passer(2);
        Global.temp_2 = Global.temp_3;
        Global.resource_amounts[Joueur exécutant.beam_target_index] -= Global.temp_2;
        Joueur exécutant.carry_resources[Joueur exécutant.resource_type] += Global.temp_2;
        Interrompre;
        Joueur exécutant.beam_target = Global.temp_1;
        Joueur exécutant.beam_target_index = Index de la valeur de tableau(Global.resource_positions, Global.temp_1);
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
        Global.temp_1 = Premier de(Tableau trié(Tableau filtré(Supprimer du tableau(Global.stash_positions, 0), Dans le champ de vision(
            Joueur exécutant, Élément de tableau actuel, 90) && Distance entre(Élément de tableau actuel, Joueur exécutant)
            <= Joueur exécutant.harvest_length && Dans la ligne de vue(Position des yeux(Joueur exécutant), Position des yeux(
            Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(Joueur exécutant),
            Élément de tableau actuel + Haut) + -1), Les barrières ne bloquent pas la ligne de vue) && Distance entre(Position des yeux(
            Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(Élément de tableau actuel + Vecteur(0, 1, 0)
            - Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)), Élément de tableau actuel + Vecteur(0, 1, 0))
            <= 2.750), Angle entre deux vecteurs(Regard en direction de(Joueur exécutant), Direction(Position des yeux(Joueur exécutant),
            Élément de tableau actuel + Vecteur(0, 1, 0)))));
        Joueur exécutant.beam_target_index = Index de la valeur de tableau(Global.stash_positions, Global.temp_1);
        Passer(1);
        Global.temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
            <= Joueur exécutant.harvest_length + 0.250);
        Passer si(Global.temp_1 == Vrai && Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type] > 0, 6);
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.who_can_see_harvest_beam = Non applicable;
        Joueur exécutant.active_beam_type = Faux;
        Joueur exécutant.primary_blocked = Vrai;
        Joueur exécutant.is_stealing = Faux;
        Interrompre;
        Passer si(Joueur exécutant.active_beam_type != 2, 15);
        Global.temp_3 = Joueur exécutant.harvest_power;
        Passer si(
            Joueur exécutant.harvest_power <= Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type],
            4);
        Global.temp_3 = Joueur exécutant.carry_limit - Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
        Passer si(
            Joueur exécutant.carry_resources[Joueur exécutant.resource_type] < Joueur exécutant.carry_limit || Joueur exécutant.message_cooldown > Temps total écoulé,
            2);
        Message en petit(Joueur exécutant, Chaîne personnalisée("Carrying capacity reached"));
        Joueur exécutant.message_cooldown = Temps total écoulé + 3;
        Passer si(Global.temp_3 < Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type], 3);
        Global.temp_2 = Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type];
        Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1).stash_resources[Joueur exécutant.resource_type] = 0;
        Passer(2);
        Global.temp_2 = Global.temp_3;
        Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type] -= Global.temp_2;
        Joueur exécutant.carry_resources[Joueur exécutant.resource_type] += Global.temp_2;
        Joueur exécutant.loyalty_hidden -= Joueur exécutant.is_stealing * Global.temp_2 * Joueur exécutant.stealing_modifier * 2;
        Interrompre;
        Joueur exécutant.beam_target = Global.temp_1;
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
        Global.temp_1 = Premier de(Tableau trié(Tableau filtré(Supprimer du tableau(Global.stash_positions, 0), Dans le champ de vision(
            Joueur exécutant, Élément de tableau actuel, 90) && Distance entre(Élément de tableau actuel, Joueur exécutant)
            <= Joueur exécutant.dispense_length && Dans la ligne de vue(Position des yeux(Joueur exécutant), Position des yeux(
            Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(Joueur exécutant),
            Élément de tableau actuel + Haut) + -1), Les barrières ne bloquent pas la ligne de vue) && Distance entre(Position des yeux(
            Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(Élément de tableau actuel + Vecteur(0, 1, 0)
            - Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)), Élément de tableau actuel + Vecteur(0, 1, 0))
            <= 2.750), Angle entre deux vecteurs(Regard en direction de(Joueur exécutant), Direction(Position des yeux(Joueur exécutant),
            Élément de tableau actuel + Vecteur(0, 1, 0)))));
        Joueur exécutant.beam_target_index = Index de la valeur de tableau(Global.stash_positions, Global.temp_1);
        Passer(1);
        Global.temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
            <= Joueur exécutant.dispense_length + 0.250);
        Passer si(Global.temp_1 == Vrai && Joueur exécutant.carry_resources[Joueur exécutant.resource_type] > 0, 7);
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.who_can_see_dispense_beam = Non applicable;
        Passer si(Joueur exécutant.active_beam_type == Vrai, 1);
        Joueur exécutant.check_secondary_delivery = Vrai;
        Joueur exécutant.active_beam_type = Faux;
        Joueur exécutant.secondary_blocked = Vrai;
        Interrompre;
        Passer si(Joueur exécutant.active_beam_type != 3, 14);
        Global.temp_3 = Joueur exécutant.dispense_power;
        Passer si(Joueur exécutant.dispense_power <= Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_limit - Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type], 4);
        Global.temp_3 = Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1).stash_limit - Joueurs dans l’emplacement(
            Joueur exécutant.beam_target_index, Équipe 1).stash_resources[Joueur exécutant.resource_type];
        Passer si(Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type] < Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_limit || Joueur exécutant.message_cooldown > Temps total écoulé, 2);
        Message en petit(Joueur exécutant, Chaîne personnalisée("Stash capacity reached"));
        Joueur exécutant.message_cooldown = Temps total écoulé + 3;
        Passer si(Global.temp_3 < Joueur exécutant.carry_resources[Joueur exécutant.resource_type], 3);
        Global.temp_2 = Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
        Joueur exécutant.carry_resources[Joueur exécutant.resource_type] = 0;
        Passer(2);
        Global.temp_2 = Global.temp_3;
        Joueur exécutant.carry_resources[Joueur exécutant.resource_type] -= Global.temp_2;
        Joueurs dans l’emplacement(Joueur exécutant.beam_target_index, Équipe 1)
            .stash_resources[Joueur exécutant.resource_type] += Global.temp_2;
        Interrompre;
        Joueur exécutant.beam_target = Global.temp_1;
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
        Global.temp_1 = Tableau filtré(Global.overseer_position, Dans le champ de vision(Joueur exécutant, Global.overseer_position, 90)
            && Distance entre(Global.overseer_position, Joueur exécutant) <= Joueur exécutant.dispense_length && Dans la ligne de vue(
            Position des yeux(Joueur exécutant), Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * (
            Distance entre(Position des yeux(Joueur exécutant), Global.overseer_position + Haut) + -1),
            Les barrières ne bloquent pas la ligne de vue) && Distance entre(Position des yeux(Joueur exécutant) + Regard en direction de(
            Joueur exécutant) * Produit scalaire(Global.overseer_position + Haut - Position des yeux(Joueur exécutant),
            Regard en direction de(Joueur exécutant)), Global.overseer_position + Haut) <= 3);
        Passer si(Global.temp_1 != Tableau vide, 1);
        Global.temp_1 = Tableau filtré(Global.black_marketeer_position, Dans le champ de vision(Joueur exécutant,
            Global.black_marketeer_position, 90) && Distance entre(Global.black_marketeer_position, Joueur exécutant)
            <= Joueur exécutant.dispense_length && Dans la ligne de vue(Position des yeux(Joueur exécutant), Position des yeux(
            Joueur exécutant) + Regard en direction de(Joueur exécutant) * (Distance entre(Position des yeux(Joueur exécutant),
            Global.black_marketeer_position + Haut) + -1), Les barrières ne bloquent pas la ligne de vue) && Distance entre(
            Position des yeux(Joueur exécutant) + Regard en direction de(Joueur exécutant) * Produit scalaire(
            Global.black_marketeer_position + Haut - Position des yeux(Joueur exécutant), Regard en direction de(Joueur exécutant)),
            Global.black_marketeer_position + Haut) <= 3);
        Passer(1);
        Global.temp_1 = Tableau filtré(Joueur exécutant.beam_target, Distance entre(Joueur exécutant.beam_target, Joueur exécutant)
            <= Joueur exécutant.dispense_length + 0.250 && (
            Joueur exécutant.beam_target == Global.overseer_position || Joueur exécutant.beam_target == Global.black_marketeer_position));
        Passer si(Global.temp_1 == Vrai && ((
            Global.temp_1 == Global.overseer_position && Joueur exécutant.carry_resources[Global.previous_resource + -1] > 0) || (
            Global.temp_1 != Global.overseer_position && Joueur exécutant.carry_resources[Joueur exécutant.resource_type] > 0)), 6);
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.who_can_see_dispense_beam = Non applicable;
        Joueur exécutant.active_beam_type = Faux;
        Joueur exécutant.secondary_blocked = Vrai;
        Joueur exécutant.is_stealing = Faux;
        Interrompre;
        Passer si(Joueur exécutant.active_beam_type < 4, 14);
        Global.temp_3 = Joueur exécutant.dispense_power;
        Passer si(Global.temp_3 < Joueur exécutant.carry_resources[Joueur exécutant.resource_type], 3);
        Global.temp_3 = Joueur exécutant.carry_resources[Joueur exécutant.resource_type];
        Joueur exécutant.carry_resources[Joueur exécutant.resource_type] = 0;
        Passer(1);
        Joueur exécutant.carry_resources[Joueur exécutant.resource_type] -= Global.temp_3;
        Passer si(Joueur exécutant.active_beam_type > 4, 4);
        Joueur exécutant.credits += Global.temp_3 * Joueur exécutant.player_prices[6];
        Joueur exécutant.loyalty_hidden += Global.temp_3;
        Joueur exécutant.contributed_in_phase += Global.temp_3;
        Interrompre;
        Joueur exécutant.credits += Global.temp_3 * Joueur exécutant.player_prices[Joueur exécutant.resource_type];
        Joueur exécutant.loyalty_hidden -= Global.temp_3 * Joueur exécutant.stealing_modifier * (0.200 + (
            Joueur exécutant.resource_type == Global.previous_resource + -1) * 0.800);
        Interrompre;
        Joueur exécutant.beam_target = Global.temp_1;
        Joueur exécutant.resource_type = (Global.temp_1 == Global.overseer_position) * (Global.previous_resource + -1) + (
            Global.temp_1 != Global.overseer_position) * Joueur exécutant.resource_type;
        Joueur exécutant.who_can_see_dispense_beam = Tous les joueurs(Équipe 1);
        Joueur exécutant.active_beam_type = 4 + (Global.temp_1 != Global.overseer_position) * 1;
        Joueur exécutant.is_stealing = Joueur exécutant.active_beam_type == 5;
        Joueur exécutant.sound_position = Joueur exécutant.beam_target;
    }
}

règle("Player Lets Go Off Primary Fire")
{
    évènement
    {
        Toute la partie - Chaque joueur;
        Équipe 1;
        Tout;
    }

    conditions
    {
        Bouton maintenu enfoncé(Joueur exécutant, Bouton(Tir principal)) == Faux;
    }

    actions
    {
        Interrompre si(Joueur exécutant.active_beam_type >= 3);
        Joueur exécutant.primary_blocked = Faux;
        Interrompre si(Joueur exécutant.active_beam_type == Faux);
        Joueur exécutant.who_can_see_harvest_beam = Non applicable;
        Joueur exécutant.active_beam_type = Faux;
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.check_primary_on_stash = Faux;
        Joueur exécutant.is_stealing = Faux;
    }
}

règle("Player Lets Go Off Secondary Fire")
{
    évènement
    {
        Toute la partie - Chaque joueur;
        Équipe 1;
        Tout;
    }

    conditions
    {
        Bouton maintenu enfoncé(Joueur exécutant, Bouton(Tir secondaire)) == Faux;
    }

    actions
    {
        Interrompre si(Joueur exécutant.active_beam_type >= 1 && Joueur exécutant.active_beam_type <= 2);
        Joueur exécutant.secondary_blocked = Faux;
        Interrompre si(Joueur exécutant.active_beam_type == Faux);
        Joueur exécutant.who_can_see_dispense_beam = Non applicable;
        Joueur exécutant.active_beam_type = Faux;
        Joueur exécutant.sound_position = Vecteur(0, 1000, 0);
        Joueur exécutant.check_secondary_delivery = Faux;
        Joueur exécutant.is_stealing = Faux;
    }
}

règle("Spawn Resources")
{
    évènement
    {
        Toute la partie - Tout le monde;
    }

    conditions
    {
        Global.resource_cooldown <= Temps total écoulé;
        Global.total_resources < 12;
    }

    actions
    {
        Attente(0.250, Ignorer la condition);
        Global.random_value = Nombre réel aléatoire(2, 72);
        Global.random_value = 3 + (0.028 * Global.random_value ^ 3 + -3.008 * Global.random_value ^ 2 + 108 * Global.random_value)
            / 72 + 0.500 * Global.random_value;
        Global.temp_1 = Valeur aléatoire dans le tableau(Tableau filtré(Global.numbers_0_11,
            Global.resource_amounts[Élément de tableau actuel] == Faux));
        Global.temp_2 = Global.spawn_center + Direction depuis des angles(Nombre réel aléatoire(0, 359.999), 0) * Global.random_value;
        Global.temp_3 = Position d’impact du rayon émis(Global.temp_2, Global.temp_2 + Vecteur(0, -10, 0), Non applicable, Non applicable,
            Faux);
        Boucle si(Distance entre(Global.temp_2, Global.temp_3) <= 0.250);
        Global.temp_3 = Position la plus proche en marchant(Global.temp_3);
        Boucle si(Vrai pour n’importe qui(Supprimer du tableau(Global.stash_positions, 0), Distance entre(Élément de tableau actuel,
            Global.temp_3) < 8));
        Boucle si(Vrai pour n’importe qui(Supprimer du tableau(Global.resource_positions, Global.zero_vector), Distance entre(
            Élément de tableau actuel, Global.temp_3) < 5));
        Boucle si(Distance entre(Global.temp_2, Global.black_marketeer_position) <= 6.500 || Distance entre(Global.temp_2,
            Global.tech_guy_position) <= 6.500);
        Global.despawn_check += (Global.despawn_check <= Temps total écoulé + 0.500) * 0.500;
        Global.resource_amounts[Global.temp_1] = Nombre entier aléatoire(1, 3) * 20 - Nombre entier aléatoire(0, 7);
        Global.total_resources += 1;
        Global.resource_cooldown = Temps total écoulé + 0.750;
        Global.resource_positions[Global.temp_1] = Global.temp_3;
        Global.resource_despawn_times[Global.temp_1] = Temps total écoulé + 120;
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
        Global.despawn_check <= Temps total écoulé;
    }

    actions
    {
        Global.despawn_check = Temps total écoulé + 1;
        Global.temp_1 = Tableau trié(Tableau filtré(Supprimer du tableau(Global.resource_despawn_times, 0),
            Élément de tableau actuel <= Temps total écoulé), Élément de tableau actuel);
        Interrompre si(Global.temp_1 == Tableau vide);
        Global.temp_1 = Premier de(Global.temp_1);
        Global.temp_2 = Index de la valeur de tableau(Global.resource_despawn_times, Global.temp_1);
        Global.resource_despawn_times[Global.temp_2] = 0;
        Global.temp_effect_position = Global.resource_positions[Global.temp_2];
        Global.resource_positions[Global.temp_2] = Global.zero_vector;
        Global.resource_amounts[Global.temp_2] = 0;
        Passer(Arrondir à l’entier(Global.temp_2 * 0.500, En dessous) * 2 + 1);
        Interrompre;
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Bleu ciel), Global.temp_effect_position, 1);
        Passer(9);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Vert), Global.temp_effect_position, 1);
        Passer(7);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Orange), Global.temp_effect_position, 1);
        Passer(5);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Citron vert), Global.temp_effect_position, 1);
        Passer(3);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Blanc), Global.temp_effect_position, 1);
        Passer(1);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Rouge), Global.temp_effect_position, 1);
        Global.total_resources -= 1;
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
        Global.stash_positions[Emplacement de(Joueur exécutant)] = 0;
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
        Global.temp_1 = Joueur exécutant.loyalty_hidden * 0.040;
        Joueur exécutant.loyalty_rank = Arrondir à l’entier(-0.008 * Global.temp_1 * Valeur absolue(Global.temp_1) + 0.800 * Global.temp_1,
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
        Distance entre(Joueur exécutant, Global.overseer_position + Bas) <= 3;
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

règle("Crouch: Player Picks Up / Puts Down Stash / NPC Interaction")
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
        Global.stash_positions[Emplacement de(Joueur exécutant)] = 0;
        Joueur exécutant.carry_resources = 0;
        Joueur exécutant.stash_position = Global.zero_vector;
        Joueur exécutant.carrying_stash = Vrai;
        Définir la vitesse de déplacement(Joueur exécutant, (100 + Joueur exécutant.upgrades[2] * 10) * (
            1 + Joueur exécutant.carrying_stash * -0.300));
        Joueur exécutant.who_can_see_stash_icon = Non applicable;
        Interrompre;
        Joueur exécutant.crouch_cooldown = Temps total écoulé + 0.250;
        Global.temp_1 = Position d’impact du rayon émis(Joueur exécutant + Haut, Joueur exécutant + Vecteur(0, -10, 0), Non applicable,
            Non applicable, Faux);
        Passer si(Distance entre(Global.temp_1, Global.tech_guy_position) > 6.500 && Distance entre(Global.temp_1,
            Global.black_marketeer_position) > 6.500 && Vrai pour tous(Supprimer du tableau(Global.stash_positions, 0), Distance entre(
            Élément de tableau actuel, Global.temp_1) >= 8) && Vrai pour tous(Global.resource_positions, Distance entre(
            Élément de tableau actuel, Global.temp_1) >= 5) && Distance entre(Global.overseer_position, Global.temp_1)
            >= 12.333 && Composante Y de(Global.temp_1) >= 0.500 && Composante Y de(Global.temp_1) <= 7, 4);
        Passer si(Joueur exécutant.message_cooldown > Temps total écoulé, 2);
        Message en petit(Joueur exécutant, Chaîne personnalisée("You cannot place your stash here"));
        Joueur exécutant.message_cooldown = Temps total écoulé + 3;
        Interrompre;
        Joueur exécutant.crouch_cooldown = Temps total écoulé + 1;
        Jouer un effet(Joueur exécutant, Son d’explosion concentrique, Couleur(Blanc), Joueur exécutant, 50);
        Joueur exécutant.who_can_see_stash_icon = Joueur exécutant;
        Définir l’activation de la capacité 1(Joueur exécutant, Joueur exécutant.sprint_cooldown <= Temps total écoulé);
        Joueur exécutant.carrying_stash = Faux;
        Joueur exécutant.stash_position = Global.temp_1;
        Joueur exécutant.previous_stash_position = Global.temp_1;
        Global.stash_positions[Emplacement de(Joueur exécutant)] = Global.temp_1;
        Définir la vitesse de déplacement(Joueur exécutant, 100 + Joueur exécutant.upgrades[2] * 10);
        Jouer un effet(Tous les joueurs(Équipe 1), Explosion concentrique, Couleur(Bleu), Joueur exécutant.stash_position + Haut, 8);
        Joueur exécutant.interest_rate = 0.001 * 0.020 * Distance entre(Joueur exécutant.stash_position, Global.overseer_position)
            * Distance entre(Joueur exécutant.stash_position, Global.overseer_position);
        Message en petit(Joueur exécutant, Chaîne personnalisée("Stash Interest Rate: {0}% per phase",
            Joueur exécutant.interest_rate * 100));
        Interrompre;
        Passer si(Distance entre(Joueur exécutant, Global.tech_guy_position) > 3.500 || Dans la ligne de vue(Position des yeux(
            Joueur exécutant), Global.tech_guy_position + Haut, Les barrières ne bloquent pas la ligne de vue) == Faux, 2);
        Joueur exécutant.crouch_hold_duration = Temps total écoulé;
        Interrompre;
        Interrompre si(Distance entre(Joueur exécutant, Global.black_marketeer_position) > 3.500 || Dans la ligne de vue(Position des yeux(
            Joueur exécutant), Global.black_marketeer_position + Haut, Les barrières ne bloquent pas la ligne de vue) == Faux);
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
        Passer si(Joueur exécutant.upgrades[Global.tech_for_sale] < 10, 2);
        Message en petit(Joueur exécutant, Chaîne personnalisée("I have no other tech for you, at the moment."));
        Interrompre;
        Passer(Global.tech_for_sale * 2 + 1);
        Interrompre;
        Message en petit(Joueur exécutant, Chaîne personnalisée("I can offer you a better harvesting beam for {0} credits.",
            Arrondir à l’entier((Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500, Au plus près)));
        Interrompre;
        Message en petit(Joueur exécutant, Chaîne personnalisée("How about an upgrade to your dispenser beam for {0} credits?",
            Arrondir à l’entier((Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500, Au plus près)));
        Interrompre;
        Message en petit(Joueur exécutant, Chaîne personnalisée("{0} credits and I'll install you a new pair of legs that move faster.",
            Arrondir à l’entier((Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500, Au plus près)));
        Interrompre;
        Message en petit(Joueur exécutant, Chaîne personnalisée("An update to your mobile storage capacity for only {0} credits.",
            Arrondir à l’entier((Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500, Au plus près)));
        Interrompre;
        Message en petit(Joueur exécutant, Chaîne personnalisée("I can build you a bigger stash for {0} credits.", Arrondir à l’entier((
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500,
            Au plus près)));
        Interrompre;
        Message en petit(Joueur exécutant, Chaîne personnalisée("I can offer you better camouflage, but it'll cost you {0} credits.",
            Arrondir à l’entier((Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500, Au plus près)));
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
        Interrompre si(Distance entre(Joueur exécutant, Global.tech_guy_position) > 3);
        Interrompre si(Joueur exécutant.upgrades[Global.tech_for_sale] >= 10);
        Global.temp_1 = Arrondir à l’entier((Joueur exécutant.upgrades[Global.tech_for_sale] + 1 + (
            Joueur exécutant.upgrades[Global.tech_for_sale] + 1) ^ 2) * 2.500, Au plus près);
        Passer si(Joueur exécutant.credits >= Global.temp_1, 3);
        Message en petit(Joueur exécutant, Chaîne personnalisée("Not enough credits."));
        Joueur exécutant.message_cooldown = Temps total écoulé + 3;
        Interrompre;
        Joueur exécutant.credits -= Global.temp_1;
        Joueur exécutant.upgrades[Global.tech_for_sale] += 1;
        Joueur exécutant.update_stats_command = Vrai;
        Jouer un effet(Joueur exécutant, Son d’explosion d’amélioration, Couleur(Blanc), Joueur exécutant, 50);
        Joueur exécutant.message_cooldown = Temps total écoulé + 3;
        Passer(Global.tech_for_sale * 2 + 1);
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
        Global.next_second == Vrai;
        Global.next_second <= Temps total écoulé;
    }

    actions
    {
        Global.next_second = Temps total écoulé + 1;
        Global.seconds_left -= 1;
        Interrompre si(Global.seconds_left > 0);
        Global.seconds_left = Nombre entier aléatoire(90, 210);
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
        Global.seconds_left > 10;
    }

    actions
    {
        Attente(0.250, Ignorer la condition);
        Global.random_value = Nombre entier aléatoire(0, Dernier(Global.rarity_pick_list) + Dernier(Global.rarity_index) + -1);
        Global.overseer_resource = Premier de(Tableau filtré(Global.rarity_pick_list, Élément de tableau actuel >= Global.random_value));
        Global.overseer_resource = Index de la valeur de tableau(Global.rarity_pick_list, Global.overseer_resource);
        Boucle si(Global.overseer_resource == Global.previous_resource || Global.rarity_index[Global.overseer_resource + -1] <= 5);
        Global.previous_resource = Global.overseer_resource;
        Global.rarity_index[0] += Global.overseer_resource != 1;
        Global.rarity_index[1] += Global.overseer_resource != 2;
        Global.rarity_index[2] += Global.overseer_resource != 3;
        Global.rarity_index[3] += Global.overseer_resource != 4;
        Global.rarity_index[4] += Global.overseer_resource != 5;
        Global.rarity_index[5] += Global.overseer_resource != 6;
        Global.rarity_index[Global.overseer_resource + -1] -= 5;
        Global.rarity_pick_list[1] = Global.rarity_index[0];
        Global.rarity_pick_list[2] = Global.rarity_pick_list[1] + Global.rarity_index[1];
        Global.rarity_pick_list[3] = Global.rarity_pick_list[2] + Global.rarity_index[2];
        Global.rarity_pick_list[4] = Global.rarity_pick_list[3] + Global.rarity_index[3];
        Global.rarity_pick_list[5] = Global.rarity_pick_list[4] + Global.rarity_index[4];
        Global.rarity_pick_list[6] = Global.rarity_pick_list[5] + Global.rarity_index[5];
        Global.tech_guy_position = Global.zero_vector;
        Global.black_marketeer_position = Global.zero_vector;
        Global.tech_for_sale = Valeur aléatoire dans le tableau(Supprimer du tableau(Section de tableau(Global.numbers_0_11, 0, 6),
            Global.tech_for_sale));
        Global.update_NPC_positions_command = 1;
        Global.default_prices[0] = (10 + 0.714 * Global.rarity_index[0]) * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[1] = (10 + 0.714 * Global.rarity_index[1]) * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[2] = (10 + 0.714 * Global.rarity_index[2]) * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[3] = (10 + 0.714 * Global.rarity_index[3]) * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[4] = (10 + 0.714 * Global.rarity_index[4]) * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[5] = (10 + 0.714 * Global.rarity_index[5]) * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[Global.overseer_resource + -1] = (44.800 + 3.200 * Global.rarity_index[Global.overseer_resource + -1])
            * Nombre réel aléatoire(0.008, 0.012);
        Global.default_prices[6] = (56 + 4 * Global.rarity_index[Global.overseer_resource + -1]) * Nombre réel aléatoire(0.008, 0.012);
        Tous les joueurs(Équipe 1).get_prices_command = 2;
        Attente(1, Ignorer la condition);
        Passer((Global.overseer_resource + -1) * 2 + 1);
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
        Passer si(Global.last_round == Vrai, 3);
        Message en grand(Tous les joueurs(Équipe 1), Chaîne personnalisée("Last Round"));
        Global.last_round = Vrai;
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
        Global.update_NPC_positions_command == Vrai;
    }

    actions
    {
        Attente(0.250, Ignorer la condition);
        Global.random_value = Nombre réel aléatoire(5.205, 72);
        Global.random_value = 3 + (0.028 * Global.random_value ^ 3 + -3.008 * Global.random_value ^ 2 + 108 * Global.random_value)
            / 72 + 0.500 * Global.random_value;
        Global.temp_1 = Global.spawn_center + Direction depuis des angles(Nombre réel aléatoire(0, 359.999), 0) * Global.random_value;
        Global.temp_2 = Position d’impact du rayon émis(Global.temp_1, Global.temp_1 + Vecteur(0, -10, 0), Non applicable, Non applicable,
            Faux);
        Boucle si(Distance entre(Global.temp_1, Global.temp_2) <= 0.250);
        Global.temp_2 = Position la plus proche en marchant(Global.temp_2);
        Boucle si(Vrai pour n’importe qui(Supprimer du tableau(Global.stash_positions, 0), Distance entre(Élément de tableau actuel,
            Global.temp_2) < 8));
        Boucle si(Vrai pour n’importe qui(Supprimer du tableau(Global.resource_positions, Global.zero_vector), Distance entre(
            Élément de tableau actuel, Global.temp_2) < 5));
        Boucle si(Distance entre(Global.temp_2, Vecteur(7.940, 26.980, 195.610)) <= 120 || Distance entre(Global.temp_2, Vecteur(86.150,
            23.600, 113.380)) <= 120);
        Boucle si(Dans la ligne de vue(Global.temp_2 + Haut, Global.temp_2 + Vecteur(1, 1, 0),
            Les barrières ne bloquent pas la ligne de vue) == Faux || Dans la ligne de vue(Global.temp_2 + Haut, Global.temp_2 + Vecteur(
            -1, 1, 0), Les barrières ne bloquent pas la ligne de vue) == Faux || Dans la ligne de vue(Global.temp_2 + Haut,
            Global.temp_2 + Vecteur(0, 1, 1), Les barrières ne bloquent pas la ligne de vue) == Faux || Dans la ligne de vue(
            Global.temp_2 + Haut, Global.temp_2 + Vecteur(0, 1, -1), Les barrières ne bloquent pas la ligne de vue) == Faux);
        Boucle si(Distance entre(Global.temp_2, Vecteur(164.030, 4.180, 268.100)) <= 3);
        Passer si(Global.update_NPC_positions_command >= 2, 3);
        Global.tech_guy_position = Global.temp_2;
        Global.update_NPC_positions_command = 2;
        Boucle;
        Boucle si(Distance entre(Global.temp_2, Global.tech_guy_position) <= 6.500);
        Global.black_marketeer_position = Global.temp_2;
        Global.update_NPC_positions_command = Faux;
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
            Joueur exécutant))), Vecteur(Composante X de(Global.tech_guy_position), 0, Composante Z de(Global.tech_guy_position))) <= 1);
        Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), Position de(Joueur exécutant) + Haut, 1);
        Téléportation(Joueur exécutant, Global.tech_guy_position);
        Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), Global.tech_guy_position + Haut, 1);
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
            Joueur exécutant))), Vecteur(Composante X de(Global.black_marketeer_position), 0, Composante Z de(
            Global.black_marketeer_position))) <= 1);
        Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), Position de(Joueur exécutant) + Haut, 1);
        Téléportation(Joueur exécutant, Global.black_marketeer_position);
        Jouer un effet(Tous les joueurs(Équipe 1), Bonne explosion, Couleur(Blanc), Global.black_marketeer_position + Haut, 1);
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
        Global.temp_1 = 1 + -0.010 * 0.250 * Joueur exécutant.loyalty_rank * Valeur absolue(Joueur exécutant.loyalty_rank);
        Joueur exécutant.player_prices[0] = Global.default_prices[0] * Global.temp_1;
        Joueur exécutant.player_prices[1] = Global.default_prices[1] * Global.temp_1;
        Joueur exécutant.player_prices[2] = Global.default_prices[2] * Global.temp_1;
        Joueur exécutant.player_prices[3] = Global.default_prices[3] * Global.temp_1;
        Joueur exécutant.player_prices[4] = Global.default_prices[4] * Global.temp_1;
        Joueur exécutant.player_prices[5] = Global.default_prices[5] * Global.temp_1;
        Joueur exécutant.player_prices[6] = Global.default_prices[6] * (1 + 0.010 * 0.250 * Joueur exécutant.loyalty_rank * Valeur absolue(
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
        Téléportation(Joueur exécutant, Global.overseer_position);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Jaune), Global.overseer_position, 1);
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

règle("AI / NPC Died")
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
        Téléportation(Joueur exécutant, Global.zero_vector);
        Attente(0.250, Ignorer la condition);
        Ressusciter(Joueur exécutant);
        Interrompre;
        Téléportation(Joueur exécutant, Global.overseer_position);
        Ressusciter(Joueur exécutant);
        Jouer un effet(Tous les joueurs(Équipe 1), Bon effet de ramassage, Couleur(Jaune), Global.overseer_position, 1);
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
        Global.temp_2 = 10 - (Joueur exécutant.loyalty_rank < 0) * Joueur exécutant.loyalty_rank;
        Joueur exécutant.beam_check_cooldown = Temps total écoulé + Global.temp_2;
        Joueur exécutant.stealing_cooldown = Temps total écoulé + Global.temp_2;
        Joueur exécutant.spam_check = Temps total écoulé + Global.temp_2;
        Définir un statut(Joueur exécutant, Non applicable, Renversé, Global.temp_2);
        Interrompre si(Joueur exécutant.loyalty_rank > -11);
        Joueur exécutant.credits *= 1 + 0.100 * (Joueur exécutant.loyalty_rank + 10);
        Global.temp_1 = Joueur exécutant.carry_limit * -0.100 * (Joueur exécutant.loyalty_rank + 10);
        Joueur exécutant.carry_resources[0] -= Global.temp_1;
        Joueur exécutant.carry_resources[1] -= Global.temp_1;
        Joueur exécutant.carry_resources[2] -= Global.temp_1;
        Joueur exécutant.carry_resources[3] -= Global.temp_1;
        Joueur exécutant.carry_resources[4] -= Global.temp_1;
        Joueur exécutant.carry_resources[5] -= Global.temp_1;
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
        Global.temp_1 = Tableau filtré(Tous les joueurs en vie(Équipe 1), Distance entre(Joueur exécutant, Élément de tableau actuel)
            <= 10 && Dans la ligne de vue(Position des yeux(Joueur exécutant), Élément de tableau actuel + Haut,
            Les barrières ne bloquent pas la ligne de vue) && Dans le champ de vision(Joueur exécutant, Élément de tableau actuel, 90));
        Passer(3);
        Global.temp_1 = Tableau filtré(Tous les joueurs en vie(Équipe 1), Distance entre(Élément de tableau actuel, Joueur exécutant)
            <= 10 && Élément de tableau actuel.loyalty_rank < 0 && Dans la ligne de vue(Position des yeux(Joueur exécutant),
            Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue) && Dans le champ de vision(Joueur exécutant,
            Élément de tableau actuel, 90));
        Passer(1);
        Global.temp_1 = Tableau filtré(Tous les joueurs en vie(Équipe 1), Distance entre(Élément de tableau actuel, Joueur exécutant)
            <= 10 && Élément de tableau actuel.loyalty_rank >= 0 && Dans la ligne de vue(Position des yeux(Joueur exécutant),
            Élément de tableau actuel + Haut, Les barrières ne bloquent pas la ligne de vue) && Dans le champ de vision(Joueur exécutant,
            Élément de tableau actuel, 90));
        Interrompre si(Global.temp_1 == Tableau vide);
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