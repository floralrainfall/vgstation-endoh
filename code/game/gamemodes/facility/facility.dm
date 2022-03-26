// FACILITY GAMEMODE
// Really bad

/datum/species/goo_creature
	name = "Goo Creature"
	override_icon = 'icons/mob/goo.dmi'

	known_languages = list(LANGUAGE_LATEX)

/datum/language/latex
	name = LANGUAGE_LATEX
	desc = "Strange blorbles."
	key = "9"
	colour = "solcom"
	speech_verb = "blorbles"
	ask_verb = "blorbles"
	exclaim_verb = "blorbles"
	flags = RESTRICTED
	syllables = list("...blorble...","...blarble...","...blerble...","...Poison.ogg...")
