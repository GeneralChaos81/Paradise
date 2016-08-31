//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/landmark/corpse
	name = "Unknown"
	var/mobname = "Unknown"  //Unused now but it'd fuck up maps to remove it now
	var/mob_species = null //Set to make a mob of another race, currently used only in ruins
	var/corpseuniform = null //Set this to an object path to have the slot filled with said object on the corpse.
	var/corpsesuit = null
	var/corpseshoes = null
	var/corpsegloves = null
	var/corpseradio = null
	var/corpseglasses = null
	var/corpsemask = null
	var/corpsehelmet = null
	var/corpsebelt = null
	var/corpsepocket1 = null
	var/corpsepocket2 = null
	var/corpseback = null
	var/corpseid = 0     //Just set to 1 if you want them to have an ID
	var/corpseidjob = null // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/corpseidaccess = null //This is for access. See access.dm for which jobs give what access. Again, put in quotes. Use "Captain" if you want it to be all access.
	var/corpseidicon = null //For setting it to be a gold, silver, centcomm etc ID
	var/timeofdeath = null
	var/coffin = 0
	var/list/cspecies = list( //list or random species, in case none is specified by mob_species
				"Abductor" = 1,
				"Diona" = 8,
				"Drask" = 8, //skin tone issue: white only
				"Grey" = 8,
				"Human" = 45, //skin tone issue: caucasian only
				"Kidan" = 8, //How to set eye color? All the vars I could find were invalid somehow
				"Machine" = 0, //Are immune to death
				"Plasmaman" = 1, //doesn't light anything on fire because it's dead.
				"Shadow" = 1,
				"Slime People" = 5,
				"Tajaran" = 15,
				"Unathi" = 15,
				"Vox" = 5,
				"Vulpkanin" = 15
				)


/obj/effect/landmark/corpse/initialize()
	if(istype(src,/obj/effect/landmark/corpse/clown))
		var/obj/effect/landmark/corpse/clown/C = src
		C.chooseRank()
	createCorpse()

/obj/effect/landmark/corpse/proc/createCorpse() //Creates a mob and checks for gear in each slot before attempting to equip it.
	var/mob/living/carbon/human/human/M = new /mob/living/carbon/human/human (src.loc)
	M.real_name = src.name
	M.timeofdeath = timeofdeath
	M.gender = pick(MALE, FEMALE)
	if(!src.mob_species)
		M.set_species(pickweight(cspecies)) //If no species specified by the mob type, select one at random
	M.set_species(src.mob_species)
	if(!src.mob_species=="Machine")
		M.death(1) //Kills the new mob if. This is so I can do an else to kill IPCs who are immune to death()
	var/obj/item/organ/external/head/head_organ = M.get_organ("head")
	if(head_organ)
		head_organ.r_facial = rand(0,255) //facial coloring
		head_organ.g_facial = rand(0,255)
		head_organ.b_facial = rand(0,255)
		head_organ.r_hair = rand(0,255) //hair coloring
		head_organ.g_hair = rand(0,255)
		head_organ.b_hair = rand(0,255)
	M.s_tone = rand (-185,34) //skin tone - this isn't being updated on the mobs
	M.r_skin = rand (0,255) //skin coloring
	M.g_skin = rand (0,255)
	M.b_skin = rand (0,255)
	M.r_markings = rand (0,255) //markings coloring, for when this can do other species
	M.g_markings = rand (0,255)
	M.b_markings = rand (0,255)
	head_organ.h_style = random_hair_style(M.gender, head_organ.species.name) // hair style
	head_organ.f_style = random_facial_hair_style(M.gender, head_organ.species.name) // facial hair style
	M.update_hair() //update icons
	M.update_fhair()
	M.update_markings()
	M.update_body()
	M.update_dna()
	if(src.corpseuniform)
		M.equip_to_slot_or_del(new src.corpseuniform(M), slot_w_uniform)
	if(src.corpsesuit)
		M.equip_to_slot_or_del(new src.corpsesuit(M), slot_wear_suit)
	if(src.corpseshoes)
		M.equip_to_slot_or_del(new src.corpseshoes(M), slot_shoes)
	if(src.corpsegloves)
		M.equip_to_slot_or_del(new src.corpsegloves(M), slot_gloves)
	if(src.corpseradio)
		M.equip_to_slot_or_del(new src.corpseradio(M), slot_l_ear)
	if(src.corpseglasses)
		M.equip_to_slot_or_del(new src.corpseglasses(M), slot_glasses)
	if(src.corpsemask)
		M.equip_to_slot_or_del(new src.corpsemask(M), slot_wear_mask)
	if(src.corpsehelmet)
		M.equip_to_slot_or_del(new src.corpsehelmet(M), slot_head)
	if(src.corpsebelt)
		M.equip_to_slot_or_del(new src.corpsebelt(M), slot_belt)
	if(src.corpsepocket1)
		M.equip_to_slot_or_del(new src.corpsepocket1(M), slot_r_store)
	if(src.corpsepocket2)
		M.equip_to_slot_or_del(new src.corpsepocket2(M), slot_l_store)
	if(src.corpseback)
		M.equip_to_slot_or_del(new src.corpseback(M), slot_back)
	if(src.corpseid == 1)
		var/obj/item/weapon/card/id/W = new(M)
		W.name = "[M.real_name]'s ID Card"
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(J.title == corpseidaccess)
				jobdatum = J
				break
		if(src.corpseidicon)
			W.icon_state = corpseidicon
		if(src.corpseidaccess)
			if(jobdatum)
				W.access = jobdatum.get_access()
			else
				W.access = list()
		if(corpseidjob)
			W.assignment = corpseidjob
		W.registered_name = M.real_name
		M.equip_to_slot_or_del(W, slot_wear_id)
	if(src.coffin == 1)
		var/obj/structure/closet/coffin/sarcophagus/sarc = locate(/obj/structure/closet/coffin/sarcophagus) in loc
		if(sarc) M.loc = sarc
	qdel(src)



///////////Syndicate//////////////////////

/obj/effect/landmark/corpse/syndicatesoldier
	name = "Syndicate Operative"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/swat
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"
	mob_species = "Human"



/obj/effect/landmark/corpse/syndicatecommando
	name = "Syndicate Commando"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/space/rig/syndi
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/syndicate
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/syndi
	corpseback = /obj/item/weapon/tank/jetpack/oxygen
	corpsepocket1 = /obj/item/weapon/tank/emergency_oxygen
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"
	mob_species = "Human"



///////////Crew//////////////////////

/obj/effect/landmark/corpse/chef
	name = "Chef"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/chef/classic
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/chefhat
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset/headset_service
	corpseid = 1
	corpseidjob = "Chef"
	corpseidaccess = "Chef"


/obj/effect/landmark/corpse/doctor
	name = "Doctor"
	corpseradio = /obj/item/device/radio/headset/headset_med
	corpseuniform = /obj/item/clothing/under/rank/medical
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpseback = /obj/item/weapon/storage/backpack/medic
	corpsepocket1 = /obj/item/device/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Medical Doctor"
	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpse/engineer
	name = "Engineer"
	corpseradio = /obj/item/device/radio/headset/headset_eng
	corpseuniform = /obj/item/clothing/under/rank/engineer
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/workboots
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/color/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Station Engineer"
	corpseidaccess = "Station Engineer"

/obj/effect/landmark/corpse/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig

/obj/effect/landmark/corpse/clown

/obj/effect/landmark/corpse/clown/proc/chooseRank()
	if(prob(10))
		name = "Clown Officer"
		corpseuniform = /obj/item/clothing/under/officeruniform
		corpsesuit = /obj/item/clothing/suit/officercoat
		corpseshoes = /obj/item/clothing/shoes/clown_shoes
		corpseradio = /obj/item/device/radio/headset
		corpsemask = /obj/item/clothing/mask/gas/clown_hat
		corpsepocket1 = /obj/item/weapon/bikehorn
		corpseback = /obj/item/weapon/storage/backpack/clown
		corpsehelmet = /obj/item/clothing/head/naziofficer
		corpseid = 1
		corpseidjob = "Clown Officer"
		corpseidaccess = "Clown"
		timeofdeath = -50000
	else
		name = "Clown Soldier"
		corpseuniform = /obj/item/clothing/under/soldieruniform
		corpsesuit = /obj/item/clothing/suit/soldiercoat
		corpseshoes = /obj/item/clothing/shoes/clown_shoes
		corpseradio = /obj/item/device/radio/headset
		corpsemask = /obj/item/clothing/mask/gas/clown_hat
		corpsepocket1 = /obj/item/weapon/bikehorn
		corpseback = /obj/item/weapon/storage/backpack/clown
		corpsehelmet = /obj/item/clothing/head/stalhelm
		corpseid = 1
		corpseidjob = "Clown Soldier"
		corpseidaccess = "Clown"
		timeofdeath = -50000

/obj/effect/landmark/corpse/clownking
	name = "Clown King"
	corpseuniform = /obj/item/clothing/under/rank/clown
	corpseshoes = /obj/item/clothing/shoes/clown_shoes
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/clown_hat
	corpsehelmet = /obj/item/clothing/head/crown
	corpsepocket1 = /obj/item/weapon/bikehorn
	corpseback = /obj/item/weapon/bedsheet/clown
	corpseid = 1
	corpseidjob = "Clown King"
	corpseidaccess = "Clown"
	timeofdeath = -50000
	coffin = 1

/obj/effect/landmark/corpse/mime
	name = "Mime"
	corpseuniform = /obj/item/clothing/under/mime
	corpseshoes = /obj/item/clothing/shoes/black
	corpseradio = /obj/item/device/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/mime
	corpseback = /obj/item/weapon/storage/backpack
	corpseid = 1
	corpseidjob = "Mime"
	corpseidaccess = "Mime"
	timeofdeath = -50000

/obj/effect/landmark/corpse/scientist
	name = "Scientist"
	corpseradio = /obj/item/device/radio/headset/headset_sci
	corpseuniform = /obj/item/clothing/under/rank/scientist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat/science
	corpseback = /obj/item/weapon/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Scientist"
	corpseidaccess = "Scientist"

/obj/effect/landmark/corpse/miner
	corpseradio = /obj/item/device/radio/headset/headset_cargo
	corpseuniform = /obj/item/clothing/under/rank/miner
	corpsegloves = /obj/item/clothing/gloves/fingerless
	corpseback = /obj/item/weapon/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/black
	corpsebelt = /obj/item/weapon/storage/bag/ore
	corpseid = 1
	corpseidjob = "Shaft Miner"
	corpseidaccess = "Shaft Miner"

/obj/effect/landmark/corpse/miner/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/mining
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/mining

/obj/effect/landmark/corpse/bartender
	name = "Bartender"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/wcoat
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/that
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset/headset_service
	corpseid = 1
	corpseidjob = "Bartender"
	corpseidaccess = "Bartender"

/obj/effect/landmark/corpse/assistant
	name = "Assistant"
	corpseuniform = /obj/item/clothing/under/color/grey
	corpsehelmet = /obj/item/clothing/head/soft/grey
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpseid = 1
	corpseidjob = "Assistant"
	corpseidaccess = "Assistant"
	//mob_species = "Vox" //this works

/obj/effect/landmark/corpse/assistant/greytide
	name = "Assistant"
	corpseuniform = /obj/item/clothing/under/color/black
	corpsehelmet = /obj/item/clothing/head/soft/black
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpsebelt = /obj/item/weapon/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/color/fyellow
	corpseid = 1
	corpseidjob = "Assistant"
	corpseidaccess = "Assistant"

/obj/effect/landmark/corpse/assistant/operative
	name = "Assistant"
	corpseuniform = /obj/item/clothing/under/chameleon
	corpsehelmet = /obj/item/clothing/head/soft/black
	corpseshoes = /obj/item/clothing/shoes/black
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset
	corpsegloves = /obj/item/clothing/gloves/color/yellow
	corpsepocket1 = /obj/item/weapon/card/emag_broken
	corpseid = 1
	corpseidjob = "Assistant"
	corpseidaccess = "Assistant"

/obj/effect/landmark/corpse/cargo
	name = "Cargo Tech"
	corpseuniform = /obj/item/clothing/under/rank/cargotech
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/soft
	corpseback = /obj/item/weapon/storage/backpack
	corpseradio = /obj/item/device/radio/headset/headset_cargo
	corpsegloves = /obj/item/clothing/gloves/fingerless
	corpseid = 1
	corpseidjob = "Cargo Technician"
	corpseidaccess = "Cargo Technician"


/////////////////Officers//////////////////////

/obj/effect/landmark/corpse/bridgeofficer
	name = "Bridge Officer"
	corpseradio = /obj/item/device/radio/headset/heads/hop
	corpseuniform = /obj/item/clothing/under/rank/centcom_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseshoes = /obj/item/clothing/shoes/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Bridge Officer"
	corpseidaccess = "Head of Personel"

/obj/effect/landmark/corpse/commander
	name = "Commander"
	corpseuniform = /obj/item/clothing/under/rank/centcom_commander
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseradio = /obj/item/device/radio/headset/heads/captain
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/combat
	corpseshoes = /obj/item/clothing/shoes/combat
	corpsepocket1 = /obj/item/weapon/lighter/zippo
	corpseid = 1
	corpseidjob = "Commander"
	corpseidaccess = "Captain"

/obj/effect/landmark/corpse/abductor //Connected to ruins, for some reason?
	name = "abductor"
	mobname = "???"
	mob_species = "abductor"
	corpseuniform = /obj/item/clothing/under/color/grey
	corpseshoes = /obj/item/clothing/shoes/combat



////////////////Random Corpse spawner//////////////////
//Allows you to place down a random spawner object and have the map randomly choose one from a list, very much like maint loot spawners.


/obj/effect/landmark/corpse/random
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"
	var/list/ctype			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)

/obj/effect/landmark/corpse/random/New()
	var/corpsetype = pickweight(ctype)
	if(corpsetype)
		new corpsetype(get_turf(src))
	qdel(src)


/obj/effect/landmark/corpse/random/crew
	name = "Crew spawner"
	ctype = list(
				/obj/effect/landmark/corpse/assistant = 20,
				/obj/effect/landmark/corpse/assistant/greytide = 12,
				/obj/effect/landmark/corpse/assistant/operative = 4,
				/obj/effect/landmark/corpse/cargo = 12,
				/obj/effect/landmark/corpse/chef = 6,
				/obj/effect/landmark/corpse/bartender = 4,
				/obj/effect/landmark/corpse/doctor = 10,
				/obj/effect/landmark/corpse/engineer = 8,
				/obj/effect/landmark/corpse/engineer/rig = 4,
				/obj/effect/landmark/corpse/scientist = 10,
				/obj/effect/landmark/corpse/miner = 6,
				/obj/effect/landmark/corpse/miner/rig = 4,
				/obj/effect/landmark/corpse/bridgeofficer = 2,
				/obj/effect/landmark/corpse/commander = 1
				)


/obj/effect/landmark/corpse/random/syndicate
	name = "Syndicate spawner"
	ctype = list(
				/obj/effect/landmark/corpse/syndicatesoldier = 5,
				/obj/effect/landmark/corpse/syndicatecommando = 1
				)