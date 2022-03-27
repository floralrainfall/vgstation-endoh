/datum/faction/goo
	name = "Latex"
	ID = GOO_GANG
	required_pref = GOO_CREATURE
	initial_role = GOO_CREATURE
	late_role = GOO_CREATURE
	desc = "Hissss!"
	logo_state = "xeno-logo"
	initroletype = /datum/role/goo
	roletype = /datum/role/goo
	playlist = "endgame"
	default_admin_voice = "Alien Hivemind"
	admin_voice_style = "alien"
	var/squad_sent = FALSE
	var/announceWhen = 0

/datum/faction/goo/OnPostSetup()
	..()
	announceWhen = world.time + rand(2.5 MINUTES, 5 MINUTES)


/datum/faction/goo/process()
	if(world.time >= announceWhen && stage < FACTION_ACTIVE)
		stage(FACTION_ACTIVE)

/datum/faction/goo/stage(var/stage)
	..()
	switch(stage)
		if(FACTION_ACTIVE)
			command_alert(/datum/command_alert/xenomorphs)
