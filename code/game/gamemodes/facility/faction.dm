/datum/faction/goo
	name = "Latex"
	ID = GOO_GANG
	required_pref = GOO_CREATURE
	initial_role = GOO_CREATURE
	late_role = GOO_CREATURE
	desc = "Blorbley people."
	logo_state = "latex-logo"
	initroletype = /datum/role/goo
	roletype = /datum/role/goo
	playlist = "endgame"
	default_admin_voice = "Latex Hivemind"
	admin_voice_style = "alien"
	var/announceWhen = 0

/datum/faction/goo/OnPostSetup()
	..()
	announceWhen = world.time + rand(2.5 MINUTES, 5 MINUTES)


/datum/faction/goo/process()
	if(world.time >= announceWhen && stage < FACTION_ACTIVE)
		stage(FACTION_ACTIVE)
/datum/command_alert/goocreature
	name = "Unidentified Transformative Lifesigns Alert"
	alert_title = "改变是有史以来最好的游戏 Alert"
	alert = 'sound/AI/aliens.ogg'

/datum/command_alert/goocreature/announce()
	message = "Unidentified transformative lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.<br><br>荣耀归于中共!"

	..()

/datum/faction/goo/stage(var/stage)
	..()
	switch(stage)
		if(FACTION_ACTIVE)
			command_alert(/datum/command_alert/xenomorphs)

/datum/role/goo/OnPostSetup(laterole = FALSE)
	. =..()
	if(!.)
		return
	if(ishuman(antag.current))
		antag.current.Gooize()

/datum/role/goo/ForgeObjectives()
	AppendObjective(/datum/objective/transform)

/datum/objective/transform
	explanation_text = "Transform a number of people."
	name = "(goo creature) Transform people"
	var/people_to_transform

/datum/objective/transform/PostAppend()
	people_to_transform = rand(4,6)
	people_to_transform = "Transform [people_to_transform] people."
	return TRUE

/datum/objective/transform/IsFulfilled()
	if (..())
		return TRUE
	if(owner)
		var/datum/role/goo/C = owner.GetRole(GOO_CREATURE)
		if(C && C.transforms >= people_to_transform)
			return TRUE
	return FALSE

/datum/stat/role/goo
	var/transforms = 0

/datum/role/goo
	name = GOO_CREATURE
	id = GOO_CREATURE
	special_role = GOO_CREATURE
	required_pref = ROLE_GOO
	wikiroute = ROLE_GOO
	logo_state = "latex-logo"
	default_admin_voice = "Latex Hivemind"
	admin_voice_style = "alien"
	var/transforms = 0

	stat_datum_type = /datum/stat/role/goo

/datum/role/goo/Greet(greeting, custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a goo creature! <br>There are precious carbons around here, and you think your brand of goo is the best!</span>")
			to_chat(antag.current, "<span class='bold'>Transform others.</span>")
			to_chat(antag.current, "<span class='bold'>Prevent other creatures from succeeding.</span>")