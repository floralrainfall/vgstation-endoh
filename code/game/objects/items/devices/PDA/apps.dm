///PDA apps by Deity Link///

//Menu values
var/global/list/pda_app_menus = list(
	PDA_APP_ALARM,
	PDA_APP_RINGER,
	PDA_APP_SPAMFILTER,
	PDA_APP_BALANCECHECK,
	PDA_APP_STATIONMAP,
	PDA_APP_NEWSREADER,
	PDA_APP_SNAKEII,
	PDA_APP_MINESWEEPER,
	PDA_APP_SPESSPETS,
	)

/datum/pda_app
	var/name = "Template Application"
	var/desc = "Template Description"
	var/price = 10
	var/menu = 0	//keep it at 0 if your app doesn't need its own menu on the PDA
	var/obj/item/device/pda/pda_device = null
	var/icon = null	//name of the icon that appears in front of the app name on the PDA, example: "pda_game.png"

/datum/pda_app/proc/onInstall(var/obj/item/device/pda/device)
	if(istype(device))
		pda_device = device
		pda_device.applications += src

/datum/pda_app/Destroy()
	if(pda_device.applications)
		pda_device.applications -= src
	pda_device = null
	..()

/////////////////////////////////////////////////

/datum/pda_app/ringer
	name = "Ringer"
	desc = "Set the frequency to that of a desk bell to be notified anytime someone presses it."
	price = 10
	menu = PDA_APP_RINGER
	icon = "pda_bell"
	var/frequency = 1457	//	1200 < frequency < 1600 , always end with an odd number.
	var/status = 1			//	0=off 1=on

/datum/pda_app/alarm
	name = "Alarm"
	desc = "Set a time for a personal alarm to trigger."
	price = 0
	//menu = PDA_APP_ALARM Don't uncomment, it's listed elsewhere by the clock
	icon = "pda_clock"
	var/target = 0
	var/status = 1			//	0=off 1=on
	var/lasttimer = 0

/datum/pda_app/alarm/proc/set_alarm(var/await)
	if(await<=0)
		return FALSE
	target = world.time + (await SECONDS)
	lasttimer = await
	spawn((await SECONDS) + 1 SECONDS)
		alarm()
	return TRUE

/datum/pda_app/alarm/proc/alarm()
	if(!status || world.time < target)
		return //End the loop if it was disabled or if the target isn't here yet. e.g.: target changed
	playsound(pda_device, 'sound/machines/chime.ogg', 40, FALSE, -2)
	var/mob/living/L = get_holder_of_type(pda_device,/mob/living)
	if(L)
		to_chat(usr, "[bicon(pda_device)]<span class='info'>Timer for [lasttimer] seconds has finished. <a href='byond://?src=\ref[pda_device];choice=restartAlarm'>(Restart?)</a></span>")

/datum/pda_app/alarm/proc/restart_alarm()
	if(!status || world.time < target || lasttimer <= 0)
		return //End the loop if it was disabled or already active
	return set_alarm(lasttimer)

/datum/pda_app/light_upgrade
	name = "PDA Flashlight Enhancer"
	desc = "Slightly increases the luminosity of your PDA's flashlight."
	price = 60
	icon = "pda_flashlight"

/datum/pda_app/light_upgrade/onInstall()
	..()
	pda_device.f_lum = 3
	if(pda_device.fon)
		pda_device.set_light(pda_device.f_lum)

/datum/pda_app/spam_filter
	name = "Spam Filter"
	desc = "Spam messages won't ring your PDA anymore. Enjoy the quiet."
	price = 30
	menu = PDA_APP_SPAMFILTER
	icon = "pda_mail"
	var/function = 1	//0=do nothing 1=conceal the spam 2=block the spam

/datum/pda_app/balance_check
	name = "Virtual Wallet and Balance Check"
	desc = "Connects to the Account Database to check the balance history the inserted ID card."
	price = 0
	icon = "pda_money"
	menu = PDA_APP_BALANCECHECK
	var/obj/machinery/account_database/linked_db

/datum/pda_app/balance_check/onInstall()
	..()
	reconnect_database()

/datum/pda_app/balance_check/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		//Checks for a database on its Z-level, else it checks for a database at the main Station.
		if((pda_device.loc && (DB.z == pda_device.loc.z)) || (DB.z == map.zMainStation))
			if((DB.stat == 0) && DB.activated )//If the database if damaged or not powered, people won't be able to use the app anymore.
				linked_db = DB
				break

/datum/pda_app/balance_check/Destroy()
	linked_db = null
	..()

/datum/pda_app/station_map
	name = "Station Holo-Map ver. 2.0"
	desc = "Displays a holo-map of the station. Useful for finding your way."
	price = 50
	menu = PDA_APP_STATIONMAP
	icon = "pda_map"
	var/obj/item/device/station_map/holomap = null

/datum/pda_app/station_map/onInstall(var/obj/item/device/pda/device)
	..()
	if (istype(device))
		holomap = new(device)

/datum/pda_app/station_map/Destroy()
	if (holomap)
		qdel(holomap)
		holomap = null
	..()

/datum/pda_app/newsreader
	name = "Newsreader"
	desc = "Access to the latest news from the comfort of your pocket."
	price = 40
	menu = PDA_APP_NEWSREADER
	icon = "pda_news"
	var/datum/feed_channel/viewing_channel
	var/screen = NEWSREADER_CHANNEL_LIST

/datum/pda_app/newsreader/proc/newsAlert(var/channel_name)
	if(pda_device.silent)
		return
	var/turf/T = get_turf(pda_device)
	playsound(T, 'sound/machines/twobeep.ogg', 50, 1)
	for (var/mob/O in hearers(3, T))
		O.show_message(text("[bicon(pda_device)] [channel_name ? "Breaking news from [channel_name]" : "Attention! Wanted issue distributed!"]!"))

///////////SNAKEII//////////////////////////////////////////////////////////////

/datum/pda_app/snake
	name = "Snake II"
	desc = "A video game. This old classic from Earth made it all the way to the far reaches of space! Includes station leaderboard."
	price = 3
	menu = PDA_APP_SNAKEII
	icon = "pda_game"
	var/volume = 6
	var/datum/snake_game/snake_game = null
	var/list/highscores = list()
	var/ingame = 0
	var/paused = 0
	var/labyrinth = 0

/datum/pda_app/snake/onInstall(var/obj/item/device/pda/device)
	..()
	for(var/x=1;x<=PDA_APP_SNAKEII_MAXSPEED;x++)
		highscores += x
		highscores[x] = list()
		var/list/templist = highscores[x]
		for(var/y=1;y<=PDA_APP_SNAKEII_MAXLABYRINTH;y++)
			templist += y
			templist[y] = 0

	snake_game = new()

/datum/pda_app/snake/Destroy()
	snake_game = null
	..()

/datum/pda_app/snake/proc/game_tick(var/mob/user)
	snake_game.game_tick(user.dir)

	game_update(user)

	if(snake_game.head.next_full)
		playsound(pda_device, 'sound/misc/pda_snake_eat.ogg', volume * 5, 1)

	if(!paused)
		if(!snake_game.gameover)
			var/snakesleep = 10 - (snake_game.level)
			spawn(snakesleep)
				game_tick(user)
		else
			game_over(user)


/datum/pda_app/snake/proc/game_update(var/mob/user)
	if(istype(user,/mob/living/carbon))
		var/mob/living/carbon/C = user
		if(C.machine && istype(C.machine,/obj/item/device/pda))
			var/obj/item/device/pda/pda_device = C.machine
			var/turf/user_loc = get_turf(user)
			var/turf/pda_loc = get_turf(pda_device)
			if(get_dist(user_loc,pda_loc) <= 1)
				if(pda_device.mode == PDA_APP_SNAKEII)
					pda_device.attack_self(C)
				else
					pause(user)
			else
				user.unset_machine()
				user << browse(null, "window=pda")
				pause(user)
		else
			pause(user)
	else
		pause(user)

/datum/pda_app/snake/proc/game_over(var/mob/user)
	playsound(pda_device, 'sound/misc/pda_snake_over.ogg', volume * 5, 0)
	for(var/i=1;i <= 4;i++)
		for(var/datum/snake/body/B in snake_game.snakeparts)
			B.flicking = 1
		snake_game.head.flicking = 1
		game_update(user)
		sleep(5)
		for(var/datum/snake/body/B in snake_game.snakeparts)
			B.flicking = 0
		snake_game.head.flicking = 0
		game_update(user)
		sleep(5)

	save_score()

	//if(snake_game.snakeparts.len >= 179)
	//TODO: achievement

	ingame = 0

	game_update(user)

/datum/pda_app/snake/proc/pause(var/mob/user)
	if(ingame)
		if(!paused)
			paused = 1
		else
			paused = 0
			game_tick(user)

/datum/pda_app/snake/proc/save_score()
	var/list/templist = highscores[snake_game.level]
	templist[labyrinth+1] = max(templist[labyrinth+1], snake_game.snakescore)

	var/list/leaderlist = snake_station_highscores[snake_game.level]
	var/list/winnerlist = snake_best_players[snake_game.level]

	if(templist[labyrinth+1] > leaderlist[labyrinth+1])
		leaderlist[labyrinth+1] = templist[labyrinth+1]
		winnerlist[labyrinth+1] = pda_device.owner

///////////MINESWEEPER//////////////////////////////////////////////////////////////

/datum/pda_app/minesweeper
	name = "Minesweeper"
	desc = "A video game. This old classic from Earth made it all the way to the far reaches of space! Includes station leaderboard."
	price = 5
	menu = PDA_APP_MINESWEEPER
	icon = "pda_game"
	var/ingame = 0
	var/datum/minesweeper_game/minesweeper_game = null


/datum/pda_app/minesweeper/onInstall(var/obj/item/device/pda/device)
	..()
	minesweeper_game = new()

/datum/pda_app/minesweeper/Destroy()
	minesweeper_game = null
	..()

/datum/pda_app/minesweeper/proc/game_tick(var/mob/user)
	sleep(1)	//to give the game the time to process all tiles if many are dug at once.
	if(minesweeper_game.gameover && (minesweeper_game.face == "win"))
		save_score()
	game_update(user)

/datum/pda_app/minesweeper/proc/game_update(var/mob/user)
	if(istype(user,/mob/living/carbon))
		var/mob/living/carbon/C = user
		if(C.machine && istype(C.machine,/obj/item/device/pda))
			var/obj/item/device/pda/pda_device = C.machine
			var/turf/user_loc = get_turf(user)
			var/turf/pda_loc = get_turf(pda_device)
			if(get_dist(user_loc,pda_loc) <= 1)
				if(pda_device.mode == PDA_APP_MINESWEEPER)
					pda_device.attack_self(C)
			else
				user.unset_machine()
				user << browse(null, "window=pda")

/datum/pda_app/minesweeper/proc/save_score()
	if(minesweeper_game.current_difficulty == "custom")
		return
	if(minesweeper_game.end_timer < minesweeper_station_highscores[minesweeper_game.current_difficulty])
		minesweeper_station_highscores[minesweeper_game.current_difficulty] = minesweeper_game.end_timer
		minesweeper_best_players[minesweeper_game.current_difficulty] = pda_device.owner

///////////SPESS PETS//////////////////////////////////////////////////////////////

/datum/pda_app/spesspets
	name = "Spess Pets"
	desc = "A virtual pet simulator. For when you don't have the balls to own a real pet. Includes multi-PDA interactions and Nanocoin mining."
	price = 10
	menu = PDA_APP_SPESSPETS
	icon = "pda_egg"
	var/obj/machinery/account_database/linked_db

	var/game_state = 0	//0 = First Startup; 1 = Egg Chosen; 2 = Egg Hatched (normal status); 3 = Pet Dead
	var/petname = "Ianitchi"
	var/petID = "000000"
	var/level = 0
	var/exp = 0
	var/race = "Corgegg"//Race set here for sanity purposes, the player chooses the race himself

	var/hatching = 0

	var/ishungry = 0
	var/isdirty = 0

	var/ishurt = 0

	var/ishappy = 0
	var/isatwork = 0
	var/issleeping = 0

	var/last_spoken = "Corgegg"

	var/area/walk_target = null
	var/last_walk_start = 0

	var/total_happiness = 0
	var/total_hunger = 0
	var/total_dirty = 0
	var/walk_completed = 0

	var/next_coin = 0
	var/total_coins = 0

	var/isfighting = 0
	var/list/challenged = list()
	var/isvisiting = 0
	var/list/visited = list()

/datum/pda_app/spesspets/onInstall(var/obj/item/device/pda/device)
	..()
	petID = num2text(rand(000000,999999))
	reconnect_database()

/datum/pda_app/spesspets/proc/reconnect_database()
	for(var/obj/machinery/account_database/DB in account_DBs)
		if((DB.z == pda_device.loc.z) || (DB.z == map.zMainStation))
			if((DB.stat == 0) && DB.activated )
				linked_db = DB
				break

/datum/pda_app/spesspets/Destroy()
	linked_db = null
	challenged = null
	visited = null
	..()

/datum/pda_app/spesspets/proc/game_tick(var/mob/user)
	if (game_state == 1)
		hatching++
		if(hatching > 1200)
			last_spoken = "Help him hatch already you piece of fuck!"
		else if(hatching > 600)
			last_spoken = "Looks like the pet is trying to hatch from the egg!"
		else if(hatching > 300)
			last_spoken = "Did the egg just move?"
		else
			last_spoken = "The egg stands still."

	if (game_state == 2)
		if(isatwork)
			isatwork--
			next_coin--
			if(next_coin <= 0)
				total_coins++
				next_coin = rand(10,15)
				if(ishappy)
					next_coin = rand(5,7)
			if(!isatwork)
				issleeping = 600

		if(issleeping)
			issleeping--
		if(ishappy)
			ishappy--
			total_happiness++
		if(ishungry)
			total_hunger++
		if(isdirty)
			total_dirty++

		if(ishurt)
			ishurt++
			if(ishurt >= 600)
				game_state = 3

		var/new_exp = 0
		if(!isdirty)
			new_exp = 1
			if(ishappy)
				new_exp = new_exp*2
			if(ishurt)
				new_exp = new_exp/2
		exp += new_exp

		if(exp > 900)
			level++
			exp = 0
			if(level >= 50)
				game_state = 3

	game_update(user)

	if(game_state < 3)
		spawn(10)
			game_tick(user)


/datum/pda_app/spesspets/proc/game_update(var/mob/user)
	if(istype(user,/mob/living/carbon))
		var/mob/living/carbon/C = user
		if(C.machine && istype(C.machine,/obj/item/device/pda))
			var/obj/item/device/pda/pda_device = C.machine
			var/turf/user_loc = get_turf(user)
			var/turf/pda_loc = get_turf(pda_device)
			if(get_dist(user_loc,pda_loc) <= 1)
				if(pda_device.mode == PDA_APP_SPESSPETS)
					pda_device.attack_self(C)
			else
				user.unset_machine()
				user << browse(null, "window=pda")
