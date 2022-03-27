// FACILITY GAMEMODE
// Really bad

/datum/gamemode/facility
	name = "Facility"
	factions_allowed = list(/datum/faction/goo)
	//Im gay

// goo creatures are effectively slime creatures with the power of transforming others
/datum/species/goo_creature
	name = "Goo"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slime
	attack_verb = "glomps"
	tacklePower = 35
	flags = NO_PAIN | NO_BREATHE | ELECTRIC_HEAL
	anatomy_flags = NO_SKIN | NO_BLOOD | NO_BONES | NO_STRUCTURE | NO_BONES | MULTICOLOR
	icobase = 'icons/mob/goo.dmi'
	blood_color = "#e0dede"
	flesh_color = "#d6cdcd"
	gender = NEUTER

	tox_mod = 2

	primitive = /mob/living/carbon/slime

	has_mutant_race = 0

	spells = list(/spell/targeted/goo_transform)
	default_language = LANGUAGE_LATEX
	known_languages = list(LANGUAGE_LATEX, LANGUAGE_SLIME)

	has_organ = list(
		"brain" =    /datum/organ/internal/brain/slime_core,
	)

/datum/language/latex
	name = LANGUAGE_LATEX
	desc = "Strange blorbles."
	key = "9"
	colour = "solcom"
	speech_verb = "blorbles"
	ask_verb = "blarbles"
	exclaim_verb = "blerbles"
	flags = RESTRICTED
	syllables = list("...blorble...","...blarble...","...blerble...","...Poison.ogg...")

/mob/living/goo_pile //serves as the corpse of goo people
	name = "puddle of goo"
	desc = "The remains of a goo person."
	stat = DEAD
	icon = null //'icons/mob/human_races/r_slime.dmi'
	icon_state = null //"slime_puddle"
	density = 0
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slime
	var/mob/living/carbon/human/goo_person

/mob/living/goo_pile/update_icon()
	if(goo_person)
		var/icon/I = new ('icons/mob/human_races/r_slime.dmi', "slime_puddle")
		I.Blend(rgb(goo_person.multicolor_skin_r, goo_person.multicolor_skin_g, goo_person.multicolor_skin_b), ICON_ADD)
		overlays += I

/mob/living/goo_pile/attack_hand(mob/user)
	if(goo_person)
		var/datum/organ/external/head = goo_person.get_organ(LIMB_HEAD)
		var/datum/organ/internal/I = goo_person.internal_organs_by_name["brain"]

		var/obj/item/organ/internal/O
		if(I && istype(I))
			O = I.remove(user)
			if(O && istype(O))

				O.organ_data.rejecting = null

				goo_person.internal_organs_by_name["brain"] = null
				goo_person.internal_organs_by_name -= "brain"
				goo_person.internal_organs -= O.organ_data
				head.internal_organs -= O.organ_data
				O.removed(goo_person,user)
				user.put_in_hands(O)
				to_chat(user, "<span class='notice'>You remove \the [O] from \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>You root around inside \the [src], but find nothing.</span>")

/datum/species/goo_creature/gib(mob/living/carbon/human/H)
	..()
	H.default_gib()

/mob/living/goo_pile/attackby(obj/item/I, mob/user)
	if(goo_person)
		if(istype(I, /obj/item/organ/internal/brain/slime_core))
			if(goo_person.internal_organs_by_name["brain"])
				to_chat(user, "<span class='notice'>There is already \a [I] in \the [src].</span>")
				return
			if(user.drop_item(I))
				var/datum/organ/external/head = goo_person.get_organ(LIMB_HEAD)
				var/obj/item/organ/internal/O = I

				if(istype(O))
					O.organ_data.transplant_data = list()
					O.organ_data.transplant_data["species"] =    goo_person.species.name
					O.organ_data.transplant_data["blood_type"] = goo_person.dna.b_type
					O.organ_data.transplant_data["blood_DNA"] =  goo_person.dna.unique_enzymes

					O.organ_data.organ_holder = null
					O.organ_data.owner = goo_person
					goo_person.internal_organs |= O.organ_data
					head.internal_organs |= O.organ_data
					goo_person.internal_organs_by_name[O.organ_tag] = O.organ_data
					O.organ_data.status |= ORGAN_CUT_AWAY
					O.replaced(goo_person)

				to_chat(user, "<span class='notice'>You place \the [O] into \the [src].</span>")
				O.stabilized = TRUE
				O.loc = null
