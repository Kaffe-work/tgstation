//base version, 1-to-1 stolen from ling

/datum/action/terminator/weapon
	name = "Organic Weapon"
	desc = "Go tell a coder if you see this"
	helptext = "Yell at Miauw and/or Perakp"
	chemical_cost = 1000
	dna_cost = -1

	var/silent = FALSE
	var/weapon_type
	var/weapon_name_simple

/datum/action/terminator/weapon/try_to_sting(mob/user, mob/target)
	for(var/obj/item/I in user.held_items)
		if(check_weapon(user, I))
			return
	..(user, target)

/datum/action/terminator/weapon/proc/check_weapon(mob/user, obj/item/hand_item)
	if(istype(hand_item, weapon_type))
		user.temporarilyRemoveItemFromInventory(hand_item, TRUE) //DROPDEL will delete the item
		if(!silent)
			playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
			user.visible_message("<span class='warning'>With a sickening crunch, [user] reforms [user.p_their()] [weapon_name_simple] into an arm!</span>", "<span class='notice'>We assimilate the [weapon_name_simple] back into our body.</span>", "<span class='italics>You hear organic matter ripping and tearing!</span>")
		user.update_inv_hands()
		return 1

/datum/action/terminator/weapon/sting_action(mob/living/user)
	var/obj/item/held = user.get_active_held_item()
	if(held && !user.dropItemToGround(held))
		to_chat(user, "<span class='warning'>[held] is stuck to your hand, you cannot grow a [weapon_name_simple] over it!</span>")
		return
	..()
	var/limb_regen = 0
	if(user.active_hand_index % 2 == 0) //we regen the arm before changing it into the weapon
		limb_regen = user.regenerate_limb(BODY_ZONE_R_ARM, 1)
	else
		limb_regen = user.regenerate_limb(BODY_ZONE_L_ARM, 1)
	if(limb_regen)
		user.visible_message("<span class='warning'>[user]'s missing arm reforms, making a loud, grotesque sound!</span>", "<span class='userdanger'>Your arm regrows, making a loud, crunchy sound and giving you great pain!</span>", "<span class='hear'>You hear organic matter ripping and tearing!</span>")
		user.emote("scream")
	var/obj/item/W = new weapon_type(user, silent)
	user.put_in_hands(W)
	if(!silent)
		playsound(user, 'sound/effects/blobattack.ogg', 30, TRUE)
	return W

/datum/action/terminator/weapon/Remove(mob/user)
	for(var/obj/item/I in user.held_items)
		check_weapon(user, I)
	..()

//fancy headers yo
/***************************************\
|***************ARM BLADE***************|
\***************************************/
/datum/action/terminator/weapon/internalgun
	name = "Arm Blade"
	desc = "todo"
	helptext = "pew pew"
	button_icon_state = "integrated sub-machinegun"
	chemical_cost = 20
	dna_cost = 2
	req_human = 1
	weapon_type = /obj/item/gun/energy/internallmg
	weapon_name_simple = "blade"

/obj/item/melee/arm_blade
	name = "arm blade"
	desc = "A grotesque blade made out of bone and flesh that cleaves through people as a hot knife through butter."
	icon = 'icons/obj/terminator_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/terminator_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/terminator_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 25
	throwforce = 0 //Just to be on the safe side
	throw_range = 0
	throw_speed = 0
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharpness = IS_SHARP
	wound_bonus = -60
	bare_wound_bonus = 20
	var/can_drop = FALSE
	var/fake = FALSE

/obj/item/gun/energy/internallmg
	name = "terminator lmg"
	desc = "An LMG that fires 3D-printed flechettes. They are slowly resupplied using the cyborg's internal power source."
	icon_state = "l6_cyborg"
	icon = 'icons/obj/guns/projectile.dmi'
	burst_size = 2
	cell_type = "/obj/item/stock_parts/cell/secborg"
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = FALSE
	use_cyborg_cell = TRUE


/obj/item/gun/energy/internalhmg
	name = "terminator hmg"
	desc = "An LMG that fires 3D-printed bullets. They are slowly resupplied using the cyborg's internal power source."
	icon_state = "l6_cyborg"
	icon = 'icons/obj/guns/projectile.dmi'
	burst_size = 2
	cell_type = "/obj/item/stock_parts/cell/secborg"
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet) //add new one with higher damage
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/gun/energy/internalhmgAP
	name = "terminator hmg"
	desc = "An LMG that fires 3D-printed bullets. They are slowly resupplied using the cyborg's internal power source."
	icon_state = "l6_cyborg"
	icon = 'icons/obj/guns/projectile.dmi'
	burst_size = 2
	cell_type = "/obj/item/stock_parts/cell/secborg"
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet) // TODO :add new one with higher damage SHOULD PROBABLY USE A TOGGLE
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/melee/arm_blade/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, terminator_TRAIT)
	if(ismob(loc) && !silent)
		loc.visible_message("<span class='warning'>A grotesque blade forms around [loc.name]\'s arm!</span>", "<span class='warning'>Our arm twists and mutates, transforming it into a deadly blade.</span>", "<span class='hear'>You hear organic matter ripping and tearing!</span>")
	if(synthetic)
		can_drop = TRUE
	AddComponent(/datum/component/butchering, 60, 80)

/obj/item/melee/arm_blade/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/table))
		var/obj/structure/table/T = target
		T.deconstruct(FALSE)

	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user) //muh copypasta

	else if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower()) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message, power requirement is so this doesn't stop unpowered doors from being pried open if you have access
			return
		if(A.locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] jams [src] into the airlock and starts prying it open!</span>", "<span class='warning'>We start forcing the [A] open.</span>", \
			"<span class='hear'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 100, target = A))
				return
		//user.say("Heeeeeeeeeerrre's Johnny!")
		user.visible_message("<span class='warning'>[user] forces the airlock to open with [user.p_their()] [src]!</span>", "<span class='warning'>We force the [A] to open.</span>", \
		"<span class='hear'>You hear a metal screeching sound.</span>")
		A.open(2)

/obj/item/melee/arm_blade/dropped(mob/user)
	..()
	if(can_drop)
		new /obj/item/melee/synthetic_arm_blade(get_turf(user))
