/*QUAKED trigger_centerprint (.5 .5 .5)
Displays a long text across the screen, during as long as the player stays inside the boundaries of the trigger
*/

void() trigger_centerprint_use =
{
	if(self.inactive == TRUE) return;

	if(player.plaqueflg == 0) sound (player, CHAN_ITEM, "raven/use_plaq.wav", 1, ATTN_NORM);
	
	if(self.spawnflags&/*plaque*/2)
	{
		if(!self.spawnflags & SPAWNFLAG_NOTOUCH)
		{
			makevectors (player.v_angle);
			vector viewvec=(self.absmax+self.absmin)*0.5-player.origin;
			if (vlen(viewvec) >= 16 || viewvec*v_forward <= 0) return;
		}
		player.plaqueflg = 1;
		player.plaqueangle = player.v_angle;
		msg_entity = player;
	 	plaque_draw(MSG_ONE,self.message);
	}
	else
	{
		if(self.wait > 0 && self.delay == 0) self.delay = time + self.wait;
	
		string s = getstring(self.message);
		WriteByte (MSG_ALL, SVC_CENTERPRINT);
		WriteString (MSG_ALL, s);
	
		if(time < self.delay)
			self.nextthink = time + 1;
		else
		{
			self.nextthink = -1;
			self.delay = 0;
		}
	}
};

void() trigger_centerprint_touch =
{
	if(other.classname != "player") return;
	
	trigger_centerprint_use();
};

void() trigger_centerprint =
{
	if(self.spawnflags&/*plaque*/2) precache_sound("raven/use_plaq.wav");
	
	InitTrigger ();
	self.use = trigger_centerprint_use;
	if(!self.spawnflags&/*plaque*/2) self.think = trigger_centerprint_use;
	
	if(!self.spawnflags & SPAWNFLAG_NOTOUCH)
		self.touch = trigger_centerprint_touch;
};

/*QUAKED trigger_aim
A volume trigger fired only if while touching it the player is also looking at any entity with the same netname as this trigger
*/
void() aim_touch =
{
	vector player_eyes, torigin, aim;

	if (other.classname != "player")
		return;

	//Check for every target to know whether it is in the player's "facing cone"
	entity t = world;
	do
	{
		t = find (t, netname, self.map);
		if (!t) return;

		makevectors (other.v_angle);
		player_eyes = other.origin + other.view_ofs;
		
		if(t.origin=='0 0 0')
			torigin = (t.absmin+t.absmax)*0.5;
		else
			torigin = t.origin;
		
		aim = torigin - player_eyes;
		if (normalize(v_forward) * normalize(aim) < self.ideal_yaw)
			continue;		// not in the facing cone

		//In the facing cone, but is it directly visible ?
		traceline(player_eyes, torigin, FALSE, self);
		if(trace_ent==t || trace_ent==player) break;
		
	} while(TRUE);
	
	//jprint("Saw ");jprint(t.classname);jprint(".");jprint(t.targetname);jprint(" at ");jprint(vtos(torigin));jprint("\n");

	if(self.cnt_summon) original_centerprint(player,getstring(self.cnt_summon));

	self.enemy = other;
	multi_trigger ();
};

void() trigger_aim =
{
	InitTrigger ();
	self.map=self.netname;
	self.netname=string_null;
	self.cnt_summon=self.message;
	self.message=0;
	self.touch = aim_touch;
};


/*QUAKED trigger_origin_transfer (1 .6 0) (-8 -8 -8) (8 8 8) ?
Special case- will play its message and transfer its target's origin to the position of its activating entity's origin.
Does NOT activate it's target, only moves it to the position of the activating entity
===================
FIELDS
.delay = A delay to wait for before performing the actual transfer after the trigger has been fired
.message = A message to display when used.
.movedir = An offset to compensate the possible unconvenient location of the activating entity's origin
*/
void trigger_origin_transfer_use ()
{
	string temp;
	local entity targ;
	
	if(self.delay)
	{
		thinktime self : self.delay;
		self.wait = self.delay;
		self.delay = 0;
		self.think = trigger_origin_transfer_use;
		return;
	}
	self.delay = self.wait;
	
	if(self.message && !deathmatch)
	{
		temp = getstring(self.message);
		centerprint(activator, temp);
	}
	
	targ = find(world, targetname, self.target);

	setorigin(targ, other.origin + self.movedir);
}

void trigger_origin_transfer ()
{
	InitTrigger();
	self.use=trigger_origin_transfer_use;
}

/*QUAKED trigger_wanderlust
Gives its targets having no goal a random destination so that they won't mechanically head towards '0 0 0'
===================
FIELDS
.failchance - default 0 - chance that trigger may fail to change a target's current destination (0 - 100%)
.speed      - default 0 - if set, overrides all targets' speed
*/
void wanderlust_move ()
{
	local vector direction;
	
	//Reset my creature owner's destination if any of the following condition is met:
	//		- has no goal
	//		- has me as a goal and is about to arrive
	//		- didn't move since last time, which means they're stuck and they'd better go elsewhere
	if(self.owner.goalentity.origin=='0 0 0' || 16 >= vlen (self.monster_last_seen - self.owner.origin) || (self.owner.goalentity==self && 80 >= vlen (self.oldorigin - self.owner.origin) && random(100)>=self.failchance))
	{
		//Randomly change my position to give a new goal
		direction_x=0;
		direction_y=18*rint(random(1,20));
		direction_z=0;
		makevectors(direction);
		setorigin(self,self.owner.origin+v_forward*self.monster_duration);
		self.oldorigin=self.origin;
		self.owner.goalentity=self;
		
		if(self.speed)
			self.owner.speed=self.speed;
	}

	//Remember where my creature owner is
	self.monster_last_seen=self.owner.origin;
	
	//Now decide when I'll fire next time
	thinktime self : random(self.button1,self.button2);
}

void trigger_wanderlust_use ()
{
	local entity targ;
	local entity wanderlust;
		
	if (self.target)
	{
		targ = world;
		do
		{
			if(self.spawnflags & 1/*Target netname*/)
				targ = find (targ, netname, self.target); //All the occurrences whose netname is self.netname
			else if(self.spawnflags & 2/*Target classname*/)
				targ = find (targ, classname, self.target); //All the occurrences of the class whose name is self.model
			else
				targ = find (targ, targetname, self.target); //All the occurrences whose targetname is self.target

			if (!targ)
				return;

			if(targ.movechain.classname!="wanderlust")
			{
				//Create a wanderlust entity (destination) for the target entity (unless there is one already)
				wanderlust=spawn();
				wanderlust.classname="wanderlust";
				wanderlust.failchance=self.failchance;
				wanderlust.monster_duration=self.monster_duration;
				wanderlust.speed=self.speed;
				wanderlust.button1=self.button1;
				wanderlust.button2=self.button2;
				if(self.spawnflags&128) setmodel(wanderlust,"models/flame.mdl");
				targ.movechain=wanderlust;
				wanderlust.owner=targ;

				wanderlust.think = wanderlust_move;
				thinktime wanderlust : 0;
			}
		}
		while (1);
	}
	else
	{
		bprint("trigger_wanderlust doesn't know what to look for.\n");
		return;
	}
}

void trigger_wanderlust ()
{
	InitTrigger();
	
	if(!self.monster_duration) self.monster_duration=256; //The distance the wanderlust entity is put away from the wanderer
	if(!self.button1) self.button1=3;
	if(!self.button2) self.button2=6;
	if(self.spawnflags&128) precache_model("models/flame.mdl");
	
	if(self.targetname)
		self.use = trigger_wanderlust_use;
	else
	{
		self.think = trigger_wanderlust_use;
		self.nextthink = time + 0.5; // Give targets a chance to spawn into the world
	}
}

/*QUAKED trigger_random
Randomly triggers only one of its targets
===================
You can adjust how likely a target will be fired by giving it a .mass
If you start giving a target a mass, give one to all the others as well.
If .mass is not set, it is considered being 1 by default.
So in order to have every target get the same chance of being chosen, give them no .mass and they'll all be 1.
Example: 3 targets of mass respectively 3, 2 and 1 --> Total cumulated mass is 6 so the 1st target will have half chances to be chosen, the 2nd 1/3 chances and the third 1/6 chances.
*/
void trigger_random_use ()
{
	local entity targ;

	//First pass: count the number of current targets (might have changed since last time)
	self.count=0;
	if (self.target)
	{
		targ = world;
		do
		{
			targ = find (targ, targetname, self.target);
			if (!targ) break;
			if(targ.mass) self.count += targ.mass; else self.count += 1;
		} while (1);
	}

	//Second pass: choose a random target and fire it
	if (self.count>0)
	{
		//Choose a random target
		float chosen_num, current_num;
		chosen_num = rint(random(1,self.count));

		//Find it
		current_num = 0;
		targ = world;
		do
		{
			targ = find (targ, targetname, self.target);
			if (!targ) break;
			if(targ.mass) current_num += targ.mass; else current_num += 1;
		} while (current_num<chosen_num);

		//Fire it
		string oldtargetname = self.target;
		self.target = targ.targetname = ftos(self.target_scale);
		SUB_UseTargets();
		self.target = targ.targetname = oldtargetname;
		if(self.spawnflags&1/*Consume*/) targ.targetname = ""; //This target is no longer able to be fired
	}
}

void trigger_random ()
{
	self.target_scale=random(1,32767);
	self.use = trigger_random_use;
}

/*QUAKED trigger_teleport_stealth (.5 .5 .5)
Any player touching this will be transported to its twin trigger_teleport_stealth entity with conservation of relative position, movement and facing angles so that the teleportation is unnoticeable.
Any non-player entity seen teleporting by the player would ruin the stealthiness, hence it's player only.
Even so the player would discover the trick if they land in a place where something suddenly appears or disappears.
So carefully use it in places with static geometry only (or even smarter: with connected objects breaking simultaneously in both places :))
Works in pairs with an identical twin trigger_teleport_stealth entity (target) standing in a same looking place in the same position.
If not meant to be one-way only, another pair must be placed 64 units away (too far away for the player to fire both pairs simultaneously);
Both pairs must reference each other through close_target to toggle one each other.
If only one pair is used, there will be no reactivation once used and the trip will be one-way, like if the player started a new map (actually a new submap) with no turning back.
Pay attention to setting to inactive (spawnflags 8) the very first "backward" trigger_teleport_stealth the player will encounter otherwise they will cross the line twice and nothing will have happened!
(except a super short 64 units long visit to the destination place!)
===================
FIELDS
.target         Points to an identical trigger_teleport_stealth standing in a same looking place in the same position.
.close_target   Points to another trigger_teleport_stealth standing 64 units away which, once touched, will teleport the player then instantly deactivate itself and reactivate this one.
*/

float IsTeleportable(entity ent)
{
	if(ent.flags & 8388608/*Don't stealth teleport*/) return FALSE;
	return ent.flags & (FL_MONSTER | FL_ITEM) || ent.movetype == MOVETYPE_FLYMISSILE || ent.movetype == MOVETYPE_BOUNCE || ent.movetype == MOVETYPE_BOUNCEMISSILE;
}

void() teleport_stealth_touch =
{
	entity	twin;
	string closetarget;

	if (self.inactive)               return;
	if (other.classname != "player") return;

	//Instantly put itself in deactivated mode to be sure it won't fire again before the player has left the volume
	self.inactive=TRUE;

	//Find its twin destination
	twin = find (world, targetname, self.target);
	while(twin!=world&&twin.classname!="trigger_teleport_stealth")
		twin = find (twin, targetname, self.target);
	if (!twin) objerror ("couldn't find target");

	//Prepare the moves
	vector offset;
	twin.inactive=TRUE;
	vector reference = self.finaldest;

/*	//Move all the entities in the player's
	entity oself = self;
	self = nextent(other);
	while(self)
	{
		if(checkclient ())
		{
			offset = self.origin - reference;
			setorigin (self, twin.finaldest + offset);
			if(self.flags&FL_MONSTER) self.flags(-)FL_ONGROUND;
		}
		self=nextent(self);
	}
	self = oself;
*/	
	//Fire the targets if any
	//SUB_UseTargets ();

	//Move the player
	offset = other.origin - reference;
	setorigin (other, twin.finaldest + offset);
	other.flags(-)FL_ONGROUND;

	//Find its backward counterpart and set it active to allow the player turning back
	if(twin.close_target)
	{
		closetarget = twin.close_target;
		twin = find (world, targetname, closetarget);
		while(twin!=world&&twin.classname!="trigger_teleport_stealth")
			twin = find (twin, targetname, closetarget);
		if (twin) twin.inactive=FALSE;
	}

};

void() trigger_teleport_stealth =
{
	InitTrigger ();
	self.finaldest = (self.absmax+self.absmin)*0.5; //Calculate the trigger's center of gravity
	self.touch = teleport_stealth_touch;
};

/*QUAKED trigger_changelevel_stealth (.5 .5 .5)
Works basically like trigger_teleport_stealth except the teleportation is cross-level (so it's not actually unnoticed, but as smooth as possible).
Better use it in places with static geometry only (objects present here and not there would lessen the smoothness)
Must target an identical trigger_changelevel_stealth (by targetname) & info_player_start (by netname) at destination.
If not meant to be one-way only, another trigger must be placed 64 units away (too far away for the player to fire both triggers simultaneously);
Pay attention to setting to inactive (spawnflags 8) the very "backward" trigger the player will encounter otherwise they will cross the line twice and nothing will have happened!
(except a super short 64 units long visit to the destination place!)
===================
FIELDS
.map            Target map. If not set, the trigger will behave like a passive info_player_start destination and only be used as a reference to offset the player landing point.
.target         Points to an identical trigger in the target map, standing in a same looking place in the same position, but with no .map property set.
*/

void() changelevel_stealth_touch =
{
	if (self.inactive) return;

	//Save the player's offset from the trigger's center of gravity in order to restore it at destination
	other.finaldest = other.origin - (self.absmax+self.absmin)*0.5;

	//Run the vanilla changelevel code
	changelevel_touch();
};

void() trigger_changelevel_stealth =
{
	InitTrigger ();
	if(self.map) self.touch = changelevel_stealth_touch;
};

/*QUAKED trigger_upset (.5 .5 .5)
Makes angry anyone touches it against its target... or the player!
===================
FIELDS
.target   Points to a target to be mad at. If not set: the player!
*/

void() trigger_upset_touch =
{
	local entity targ;
	local entity temp;
	
	if (self.inactive) return;

	if (self.target)
		targ = find (world, targetname, self.target);
	else
		targ = player;
	
	if (targ==world) return;
	
	if(other.flags & FL_MONSTER)
	{
		other.enemy = targ;
		temp=self;
		self=other;
		FoundTarget();
		self=temp;
	}

};

void() trigger_upset =
{
	InitTrigger ();
	self.touch = trigger_upset_touch;
};

/*QUAKED trigger_setproperty
Changes the value of one of its targets properties
===================
FIELDS
.delay   = delay to wait before actually doing the change
.target  = the target(s) to impact. Refers to their targetname or netname (if relevant spawnflag set) or to a few special hardcoded cases (see implementation)
.netname = the property whose value has to be changed (within a range of preset hard coded choices)
.level   = the new value for the property if it's a float property
.map     = how to inject the value. Ex.: "+" for adding the value, "-" for subtracting it (meant for flags)
.angles  = the new value for the property if it's a vector property
.msg3    = the new value for the property if it's a string property
*/
void trigger_setproperty_use ()
{
	local entity targ;
	local entity referenced;
	local entity temp;

	if(self.delay)
	{
		thinktime self : self.delay;
		self.wait = self.delay;
		self.delay = 0;
		self.think = trigger_setproperty_use;
		return;
	}
	self.delay = self.wait;

	if (self.target)
	{
		targ = world;
		do
		{
			if(self.target == "player")
				targ = find (world, classname, "player");
			else if (self.target == "activator.goalentity") //The target is the goalentity of the entity having initially called the trigger (mainly used by func_monsterspawner_nk)
				targ = activator.goalentity;
			else if (self.target == "activator") //The target is the entity having initially called the trigger (mainly used by func_train_mp)
				targ = activator;
			else if (self.target == "other") //The target is the entity having called the trigger (mainly used by func_train_mp)
				targ = other;
			else if(self.spawnflags&1) //Look for targets by netname instead of targetname
				targ = find (targ, netname, self.target);
			else
				targ = find (targ, targetname, self.target);
			if (!targ)
				return;

			//abslight
			if (self.netname == "abslight" && self.map == "+")
			{
				targ.abslight += self.level;
			}
			else if (self.netname == "abslight" && self.map == "-")
			{
				targ.abslight -= self.level;
			}
			else if (self.netname == "abslight")
			{
				targ.abslight = self.level;
			}
			//activate
			else if (self.netname == "activate" && self.map == "+")
			{
				targ.inactive = FALSE;
			}
			else if (self.netname == "activate" && self.map == "-")
			{
				targ.inactive = TRUE;
			}
			else if (self.netname == "activate" && self.map == "/")
			{
				targ.inactive = 1 - targ.inactive;
			}
			//angles
			else if (self.netname == "angles")
			{
				targ.angles = self.angles;
			}
			//button1
			else if (self.netname == "button1")
			{
				targ.button1 = self.level;
			}
			//button2
			else if (self.netname == "button2")
			{
				targ.button2 = self.level;
				if(targ.think) targ.nextthink = time;
			}
			//camera_time
			else if (self.netname == "camera_time")
			{
				targ.camera_time = time + self.level;
			}
			//cnt_polymorph
			else if (self.netname == "cnt_polymorph")
			{
				targ.cnt_polymorph = self.level;
			}
			//cnt_tome
			else if (self.netname == "cnt_tome")
			{
				targ.cnt_tome = self.level;
			}
			//cnt_white
			else if (self.netname == "cnt_white")
			{
				targ.cnt_haste = self.level;
			}
			//drawflags
			else if (self.netname == "drawflags" && self.map == "+")
			{
				targ.drawflags (+) self.level;
			}
			else if (self.netname == "drawflags" && self.map == "-")
			{
				targ.drawflags (-) self.level;
			}
			//effects
			else if (self.netname == "effects" && self.map == "+")
			{
				targ.effects (+) self.level;
			}
			else if (self.netname == "effects" && self.map == "-")
			{
				targ.effects (-) self.level;
			}
			//enemy
			else if (self.netname == "enemy")
			{
				if(self.msg3 == "player")
					referenced = find (world, classname, "player");
				else
					referenced = find (world, targetname, self.msg3);
				targ.enemy = referenced;
				if(targ.flags & FL_MONSTER)
				{
					temp=self;
					self=targ;
					FoundTarget();
					self=temp;
				}
			}
			//flags
			else if (self.netname == "flags" && self.map == "+")
			{
				targ.flags (+) self.level;
			}
			else if (self.netname == "flags" && self.map == "-")
			{
				targ.flags (-) self.level;
			}
			//frame
			else if (self.netname == "frame")
			{
				if(targ.frame != self.level) targ.frame = self.level;
			}
			//health
			else if (self.netname == "health")
			{
				targ.health = self.level;
			}
			//level
			else if (self.netname == "level")
			{
				if((targ.classname=="func_train" || targ.classname=="func_train_mp") && self.level == 0)
				{
					sound (targ, CHAN_VOICE, "misc/null.wav", 1, ATTN_NONE);
				}

				targ.level = self.level;
			}
			//message
			else if (self.netname == "message")
			{
				targ.message = self.level;
				if(targ.classname=="plaque")
				{
					//Forces the instant refresh of the displayed message with the new value
					//without needing the player to move (as long as they're touching the plaque, tho)
					temp=self;
					self=targ;
					player.plaqueflg=0;
					other=player;
					targ.touch();
					self=temp;
				}
			}
			//movechain
			else if (self.netname == "movechain")
			{
				referenced = find (world, targetname, self.msg3);bprint("Setting ");bprint(targ.targetname);bprint(".movechain to ");bprint(referenced.classname);bprint(".");bprint(referenced.targetname);bprint("\n");
				targ.movechain = referenced;
			}
			//netname
			else if (self.netname == "netname")
			{
				targ.netname = self.msg3;
			}
			//nextthink
			else if (self.netname == "nextthink")
			{
				targ.nextthink = time + self.level;
			}
			//noise1
			else if (self.netname == "noise1")
			{
				targ.noise1 = self.msg3;
			}
			//origin
			else if (self.netname == "origin")
			{
				setorigin (targ, self.origin);
			}
			//owner
			else if (self.netname == "owner")
			{
				if(self.msg3 == "player")
					referenced = find (world, classname, "player");
				else
					referenced = find (world, targetname, self.msg3);

				targ.owner = referenced;
			}
			//skin
			else if (self.netname == "skin")
			{
				targ.skin = self.level;
			}
			//solid
			else if (self.netname == "solid")
			{
				targ.solid = self.level;
			}
			//spawnflags
			else if (self.netname == "spawnflags" && self.map == "+")
			{
				targ.spawnflags (+) self.level;
			}
			else if (self.netname == "spawnflags" && self.map == "-")
			{
				targ.spawnflags (-) self.level;
			}
			//speed
			else if (self.netname == "speed")
			{
				targ.speed = self.level;
			}
			//takedamage
			else if (self.netname == "takedamage")
			{
				targ.takedamage=self.level;
			}
			//target
			else if (self.netname == "target")
			{
				targ.target=self.msg3;
			}
			//targetname
			else if (self.netname == "targetname")
			{
				targ.targetname=self.msg3;
			}
			//velocity
			else if (self.netname == "velocity")
			{
				targ.velocity = self.angles;
			}
			//wait
			else if (self.netname == "wait")
			{
				targ.wait=self.level;
			}
			//otherwise
			else
			{
				bprint("trigger_setproperty didn't know what to do\n");
				eprint(self);
			}
			
			//Special cases where there is only one target by design, so no looping needed (which would lead to an infinite loop!)
			if(self.target == "player" || self.target == "other" || self.target == "activator" || self.target == "activator.goalentity") break;
		} while (1);
	}
}

void trigger_setproperty ()
{
	InitTrigger();
	self.use=trigger_setproperty_use;
}
