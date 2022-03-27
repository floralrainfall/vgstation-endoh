// FACILITY GAMEMODE
// Really bad
// transform

/spell/targeted/goo_transform
	name = "Transform"
	desc = "Transform someone else into a creature like you."
	panel = "Goo"
	spell_flags = USER_TPYE_GOO
	school = "gay"

	charge_type = Sp_RECHARGE
	charge_max = 300

	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	selection_type = "view"
	spell_flags = WAIT_FOR_CLICK 
	
	override_base = "genetic"
	hud_state = "gen_eat"
	cast_sound = 'sound/items/eatfood.ogg'

	compatible_mobs = list(
		/mob/living/carbon/human
		)

/spell/targeted/goo_transform/is_valid_target(var/target)
	if(!(spell_flags & INCLUDEUSER) && target == usr)
		return 0
	if(get_dist(usr, target) > range)
		return 0
	return is_type_in_list(target, compatible_mobs)

/spell/targeted/goo_transform/proc/doHeal(var/mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H=user
		for(var/datum/organ/external/affecting in H.organs)
			affecting.heal_damage(4, 0)

		H.UpdateDamageIcon()
		H.updatehealth()

/spell/targeted/goo_transform/cast(list/targets, mob/user)
	if(!targets || !targets.len)
		return 0
	var/atom/movable/the_item = targets[1]
	var/datum/role/goo/G = user.mind.GetRole(GOO_CREATURE)
	if(!the_item || !the_item.Adjacent(user))
		return
	// if(istype(the_item, /obj/item/organ/external/head))
	// 	to_chat(user, "<span class='warning'>You try to put the [the_item] in your mouth, but the ears tickle your throat!</span>")
	// 	return 0
	// else if(isbrain(the_item))
	// 	to_chat(user, "<span class='warning'>You try to put [the_item] in your mouth, but the texture makes you gag!</span>")
	// 	return 0
	if(ishuman(the_item))
		//My gender
		var/mob/living/carbon/human/H = the_item
		user.visible_message("<span class='danger'>[user] begins splortching goo all over [the_item]!</span>")
		if(!do_mob(user, the_item,EAT_MOB_DELAY))
			to_chat(user, "<span class='warning'>You were interrupted before you could transform [the_item]!</span>")
		else
			user.visible_message("<span class='danger'>[user] transforms [the_item]!</span>", \
			"<span class='danger'>You transform [the_item].</span>")
			playsound(user, 'sound/items/eatfood.ogg', 50, 0)
			message_admins("[user] transformed [the_item]: (<A href='?_src_=holder;jumpto=\ref[user]'><b>Jump to</b></A>)")
			log_game("[user] transformed \the [the_item] at [user.x], [user.y], [user.z]")
			H.Gooize()
			doHeal(user)
			G.transforms += 1
	else
		to_chat(user, "<span class='warning'>You feel as if it wasnt conscious enough.</span>")
	return
