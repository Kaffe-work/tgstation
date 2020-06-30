//buy upgrades here, for now 1-1 steal from changeling, someone with UI should work here.
/datum/hardware_integrater
	var/name = "cellular emporium"
	var/datum/antagonist/terminator/terminator

/datum/hardware_integrater/New(my_terminator)
	. = ..()
	terminator = my_terminator

/datum/hardware_integrater/Destroy()
	terminator = null
	. = ..()

/datum/hardware_integrater/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CellularEmporium", name, 900, 480, master_ui, state)
		ui.open()

/datum/hardware_integrater/ui_data(mob/user)
	var/list/data = list()

	var/can_readapt = terminator.canrespec
	var/genetic_points_remaining = terminator.geneticpoints
	var/absorbed_dna_count = terminator.absorbedcount
	var/true_absorbs = terminator.trueabsorbs

	data["can_readapt"] = can_readapt
	data["genetic_points_remaining"] = genetic_points_remaining
	data["absorbed_dna_count"] = absorbed_dna_count

	var/list/abilities = list()

	for(var/path in terminator.all_powers)
		var/datum/action/terminator/ability = path

		var/dna_cost = initial(ability.dna_cost)
		if(dna_cost <= 0)
			continue

		var/list/AL = list()
		AL["name"] = initial(ability.name)
		AL["desc"] = initial(ability.desc)
		AL["helptext"] = initial(ability.helptext)
		AL["owned"] = terminator.has_sting(ability)
		var/req_dna = initial(ability.req_dna)
		var/req_absorbs = initial(ability.req_absorbs)
		AL["dna_cost"] = dna_cost
		AL["can_purchase"] = ((req_absorbs <= true_absorbs) && (req_dna <= absorbed_dna_count) && (dna_cost <= genetic_points_remaining))

		abilities += list(AL)

	data["abilities"] = abilities

	return data

/datum/hardware_integrater/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("readapt")
			if(terminator.canrespec)
				terminator.readapt()
		if("evolve")
			var/sting_name = params["name"]
			terminator.purchase_power(sting_name)

/datum/action/innate/hardware_integrater
	name = "Cellular Emporium"
	icon_icon = 'icons/obj/drinks.dmi'
	button_icon_state = "terminatorsting"
	background_icon_state = "bg_terminator"
	var/datum/hardware_integrater/hardware_integrater

/datum/action/innate/hardware_integrater/New(our_target)
	. = ..()
	button.name = name
	if(istype(our_target, /datum/hardware_integrater))
		hardware_integrater = our_target
	else
		CRASH("hardware_integrater action created with non emporium")

/datum/action/innate/hardware_integrater/Activate()
	hardware_integrater.ui_interact(owner)
