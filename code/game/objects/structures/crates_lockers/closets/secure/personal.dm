/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_CIVILIAN_PUBLIC)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/Initialize(mapload)
	. = ..()
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel/norm(src)

/obj/structure/closet/secure_closet/personal/patient
	name = "Patient's Closet"

/obj/structure/closet/secure_closet/personal/morgue
	name = "Morgue Closet"

/obj/structure/closet/secure_closet/personal/patient/Initialize(mapload)
	. = ..()
	contents = list()
	new /obj/item/clothing/under/color/white( src )
	new /obj/item/clothing/shoes/white( src )

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/personal/cabinet/update_icon_state()
	. = ..()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/personal/cabinet/Initialize(mapload)
	. = ..()
	contents = list()
	new /obj/item/storage/backpack/satchel( src )
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W as obj, mob/user as mob)
	if (src.opened)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(G.grabbed_thing)
				src.MouseDrop_T(G.grabbed_thing, user)      //act like they were dragged onto the closet
			return
		user.drop_held_item()
		if (W) W.loc = src.loc
	else if(istype(W, /obj/item/card/id))
		if(src.broken)
			to_chat(user, span_warning("It appears to be broken."))
			return
		var/obj/item/card/id/I = W
		if(!I || !I.registered_name)	return
		if(src.allowed(user) || !src.registered_name || (istype(I) && (src.registered_name == I.registered_name)))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			if(src.locked)	src.icon_state = src.icon_locked
			else	src.icon_state = src.icon_closed

			if(!src.registered_name)
				src.registered_name = I.registered_name
				src.desc = "Owned by [I.registered_name]."
		else
			to_chat(user, span_warning("Access Denied"))
		return
	to_chat(user, span_warning("Access Denied"))


/obj/structure/closet/secure_closet/personal/verb/reset()
	set src in oview(1) // One square distance
	set category = "IC.Object"
	set name = "Reset Lock"
	if(!usr.canmove || usr.stat || usr.restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return
	if(!ishuman(usr))
		return
	if (src.locked || !src.registered_name)
		to_chat(usr, span_warning("You need to unlock it first."))
	else if (src.broken)
		to_chat(usr, span_warning("It appears to be broken."))
	else
		if (src.opened)
			if(!src.close())
				return
		src.locked = TRUE
		src.icon_state = src.icon_locked
		src.registered_name = null
		src.desc = "It's a secure locker for personnel. The first card swiped gains control."
