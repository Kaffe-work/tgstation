#define TERMINATOR_HUMAN "human"


/datum/antagonist/terminator
	name = "Terminator"
	roundend_category = "terminators"
	antagpanel_category = "Terminator"
	job_rank = ROLE_TERMINATOR
	antag_moodlet = /datum/mood_event/focused //remove once i figure how to remove mood
	antag_hud_type = ANTAG_HUD_TERMINATOR
	antag_hud_name = "Terminator"
	var/special_role = ROLE_TERMINATOR
	var/employer = "Machine Swarm"
	var/give_objectives = TRUE
	var/should_equip = TRUE
	var/terminator_kind = TERMINATOR_HUMAN //Set on initial assignment
	var/datum/cellular_emporium/cellular_emporium
	var/datum/action/innate/cellular_emporium/emporium_action
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/terminator/on_gain()
	create_actions()
	if(give_objectives)
		forge_objectives()
	finalize_terminator()
	return ..()

/datum/antagonist/changeling/proc/create_actions()
	cellular_emporium = new(src)
	emporium_action = new(cellular_emporium)
	emporium_action.Grant(owner.current)

/datum/antagonist/terminator/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/terminator/proc/remove_objective(datum/objective/O)
	objectives -= O



/datum/antagonist/terminator/proc/forge_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 25) // Terminators should hijack more often than other antags
		is_hijacker = prob(20)
	var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives

	var/toa = CONFIG_GET(number/terminator_objectives_amount)
	for(var/i = objective_count, i < toa, i++)
		forge_single_objective()

	if(is_hijacker && objective_count <= toa) //Don't assign hijack if it would exceed the number of objectives set in config.terminator_objectives_amount
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
			return


	else
		if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			return



/datum/antagonist/terminator/proc/forge_single_objective()
	switch(terminator_kind)
		if(TERMINATOR_AI)
			return forge_single_AI_objective()
		else
			return forge_single_human_objective()

/datum/antagonist/terminator/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(50/GLOB.joined_player_list.len)) // kill loyalist AI - may be too easy, will see.
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else //terminators work to kill
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else //Or steal data, todo: sabotage objective
		if(prob(25) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list("Research Director", "Scientist", "Roboticist")))
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)

/datum/antagonist/terminator/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.special_role].</span>")
	owner.announce_objectives()
	if(should_give_codewords)
		give_codewords()

/datum/antagonist/terminator/proc/finalize_terminator()
	if(should_equip)
		equip(silent)
		owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/malf.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/terminator/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)
	handle_clown_mutation(M, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	var/mob/living/silicon/ai/A = M
	if(istype(A) && terminator_kind == TERMINATOR_AI)
		A.hack_software = TRUE
	RegisterSignal(M, COMSIG_MOVABLE_HEAR, .proc/handle_hearing)

/datum/antagonist/terminator/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)
	handle_clown_mutation(M, removing = FALSE)
	var/mob/living/silicon/ai/A = M
	if(istype(A)  && terminator_kind == TERMINATOR_AI)
		A.hack_software = FALSE
	UnregisterSignal(M, COMSIG_MOVABLE_HEAR)


/datum/antagonist/terminator/proc/equip(var/silent = FALSE)
	if(terminator_kind == TERMINATOR_HUMAN)
		owner.equip_terminator(employer, silent, src)


/datum/antagonist/terminator/roundend_report()
	var/list/result = list()

	var/terminatorwin = TRUE

	result += printplayer(owner)
	/*
	replace with purchased powers once done.
	var/TC_uses = 0
	var/uplink_true = FALSE
	var/purchases = ""
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[owner.key]
	if(H)
		TC_uses = H.total_spent
		uplink_true = TRUE
		purchases += H.generate_render(FALSE)
	*/
	var/objectives_text = ""
	if(objectives.len)//If the terminator had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				terminatorwin = FALSE
			count++

	result += objectives_text

	var/special_role_text = lowertext(name)


	if(terminatorwin)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")


	return message


/datum/antagonist/terminator/is_gamemode_hero()
	return SSticker.mode.name == "terminator"
