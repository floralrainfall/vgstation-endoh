/obj/machinery/computer/advanced
	name = "advanced computer"
	icon = 'icons/obj/computer.dmi'
	var/window_data = ""
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	circuit = null //if circuit==null, computer can't disassembly
	processing = 0
	empproof = FALSE // For plasma glass builds
	machine_flags = EMAGGABLE | SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | MULTITOOL_MENU | SHUTTLEWRENCH
	pass_flags_self = PASSMACHINE
	use_auto_lights = 1
	light_power_on = 1
	light_range_on = 3

/obj/machinery/computer/advanced/attack_ai(user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/advanced/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/computer/advanced/attack_hand(var/mob/user)
	. = ..()

	if(.)
		return
