/*QUAKED func_doomdoor (1 .8 0) (-16 -16 0) (16 16 56)
Slice of a door à la Doom upper-pegged door
*/
void LinkSlices (void)
{
	self.owner = self;
	vector direction = self.movedir;

	//Find the next func_doomdoor
	entity finalslice = self; //The last slice of the door
	entity myself = self;
	entity next = world;
	do
	{
		next = find (next, netname, self.netname);
		if (!next) break;
		if(next.absmin != myself.absmin + direction || next.classname != "func_doomdoor") continue;
		finalslice = next; //The last slice of the door... until the next loop, maybe.
		next.netname = string_null;

		//Chaining links
		next.owner = self;
		next.controller = myself;
		myself.enemy = next;
		
		//Preparing the next loop
		myself = next;
		next = world;
		
	} while (1);

	self.goalentity = finalslice;
}

void doomdoor_use (void);
void doomdoor_advance (void)
{
	if(self.owner.state == 1)
	{
		if(!self.enemy)
		{
			//End of move
			self.owner.state = 0;
			self.nextthink = -1;
			
			//The last slice becomes the targeting entry point to allow back move
			self.targetname = self.owner.targetname;
			self.owner.targetname = string_null;
			
			//Auto-return, if applicable
			if (self.owner.wait > 0)
			{
				self.think = doomdoor_use;
				self.nextthink = time + self.owner.wait;
			}
		}
		else
		{
			self = self.enemy;
			self.use();
		}
	}
	else
	{
		if(!self.controller)
		{
			//End of move
			self.owner.state = 1;
			self.nextthink = -1;

			//The first slice becomes the targeting entry point to return to primary move
			self.owner.targetname = self.goalentity.targetname;
			self.goalentity.targetname = string_null;			
		}
		else
		{
			self = self.controller;
			self.use();
		}
	}
}

void doomdoor_use (void)
{
	//Nice alternate texture effect on the edge of move
	if(self.enemy) self.enemy.frame = self.owner.state;
	
	if(self.owner.state == 1)
	{
		self.solid = SOLID_NOT;
		setmodel (self, "");
	}
	else
	{
		self.solid = SOLID_SLIDEBOX;
		setmodel (self, self.mdl);
	}

	self.think = doomdoor_advance;
	self.nextthink = time + 0.025;
}

void func_doomdoor (void)
{
	SetMovedir ();
	setorigin (self, self.origin);
	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_SLIDEBOX;
	setmodel (self, self.model);
	self.mdl = self.model; // so it can be restored on return
	
	if(!self.wait)  self.wait = -1;

	self.use = doomdoor_use;
	
	if(self.targetname)
	{
		self.state = 1;
		
		// LinkSlices can't be done until all of the slices have been spawned, so
		// the sizes can be detected properly.
		self.think = LinkSlices;
		self.nextthink = self.ltime + 0.1;
	}
}

/*QUAKED func_playtrack (1 .8 0) (-16 -16 0) (16 16 56)
Plays the CD track or music file in self.sounds
Range [2-11] (or higher values)


void func_playtrack_use (void)
{
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, self.sounds);
	WriteByte (MSG_ALL, self.sounds);
}

void func_playtrack (void)
{
	setsize(self,'-8 -8 -8','8 8 8');
	setorigin(self,self.origin);
	self.use=func_playtrack_use;
}
*/
/*QUAKED func_playerclip
A bbox entity which is solid for the player only
*/
void() func_playerclip =
{
	setmodel (self, self.model);	// set size and link into world
};

/*QUAKED func_veil
A bbox entity which is non solid and can be killed (unlike the func_illusionary)
*/
void() func_veil =
{
	if (self.spawnflags & 1) 
		self.drawflags (+) DRF_TRANSLUCENT;

	if (self.abslight)
		self.drawflags (+) MLS_ABSLIGHT;
	
	setmodel (self, self.model);	// set size and link into world
	self.solid=SOLID_NOT;
};

/*QUAKED func_lightstyle (1 .6 0) (-8 -8 -8) (8 8 8) ?
Global lightstyle changer
===================
FIELDS
.style   = the light style whose brightness animation pattern has to be changed
.netname = a string containing the new brightness animation pattern to set
*/
void func_lightstyle_use()
{
	lightstyle(self.style, self.netname);
}

void() func_lightstyle =
{
	if (!self.style) objerror("func_lightstyle without a target style");
	if (!self.netname) objerror("func_lightstyle without a netname brightness animation pattern");
	self.use = func_lightstyle_use;
}
