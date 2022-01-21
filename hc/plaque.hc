/*
 * $Header: /H2 Mission Pack/HCode/plaque.hc 4     2/16/98 11:48a Jweier $
 */

float PLAQUE_INVISIBLE = 1;
float PLAQUE_ACTIVATE  = 2;

void() ImpulseCommands; //Inky: 20200609

/*
================
plague_use

Activate a plaque
================
RPG howto:
level               says how many choices the plaque's message offers to the player. Only when reading a plaque with such a range a player can make a choice
                    (prevents choices input by mistake during normal play even without reading any plaque or before doing so)
                    when the player chooses, the plaque's message becomes its initial message number + the player choice number (= the player's worldtype property)
					Exception:
					For long messages spreading over more than one page, the initial plaque will have self.level==2 so that the "next" command is always 2 (more consistent UX).
					The 1 command should then be explicitly ignored by setting self.puzzle_piece_1 to blank.
target              let the reading of the plaque trigger targets
killtarget          let the reading of the plaque kill targets
wait				If -1, SUB_UseTargets is called upon first reading only
puzzle_piece_1..4   if set, when the player makes a choice, instead of displaying the corresponding message based on the offset, the control goes to a brand new plaque
                    whose targetname is puzzle_piece_N (which must be initially deactivated). Useful for chaining choices.
					puzzle_piece_N may be anything else instead (a trigger, a func_door...): it's activated (in case it's deactivated initially) then its use() function is called, if it has one.
*/
void plaque_use (void)
{
	if (self.spawnflags & PLAQUE_ACTIVATE)
		self.inactive = 0;
}

void plaque_touch (void)
{
	vector	spot1, spot2;	
	float tmpmessage,msg_incr;
	string nexttargetname;
	entity nextplaque;
	
	if (self.inactive)
		return;

	//Inky: 20200609 RPG support
	if(other.classname == "player")
	{
		//Player's worldtype property taken into account only if the plaque is set up for it, otherwise it's reset. 
		if(other.worldtype>self.level)
			other.worldtype=0;
	
		msg_incr = other.worldtype;
		
		//Player's worldtype property taken into account only once: then self.level is reset to 0 to prevent more answers and ensure a single forward-only dialog.
		//The plaqueflg property is reset as well, so that the subsequent message can be displayed without forcing the player to leave the plaque then come back.
		if(other.worldtype > 0)
		{
			self.waterlevel = self.level;
			other.plaqueflg = 0;
			
			if(!(self.level==2 && self.puzzle_piece_1=="" && other.worldtype == 1))
				self.level = 0;

			//Inky 20220117 Specific treatment of the starting page of a multi-pages message
			if(self.level==2 && self.puzzle_piece_1=="")
			{
				msg_incr = other.worldtype - 1; //Hack to ignore a "previous" command and treat a "next" command as "self.message++"
			}			
		}
		
		//Trigger behavior
		tmpmessage = self.message + msg_incr;
		self.message = 0;
		if(self.wait>-2)
			SUB_UseTargets();
		if(self.wait==-1)
			self.wait=-2;
		self.message = tmpmessage;
		
		if(other.worldtype > 0)
		{
			//Jump to the next plaque if any
			if(other.worldtype==1)
				nexttargetname = self.puzzle_piece_1;
			else if(other.worldtype==2)
				nexttargetname = self.puzzle_piece_2;
			else if(other.worldtype==3)
				nexttargetname = self.puzzle_piece_3;
			else if(other.worldtype==4)
				nexttargetname = self.puzzle_piece_4;
			else
				nexttargetname = "";
			
			if(nexttargetname != "")
			{
				nextplaque = find(world, targetname, nexttargetname);
				if(nextplaque)
				{
					other.plaqueflg = 0;
					other.worldtype=0;
					self.inactive = TRUE;
					if(nextplaque.classname=="plaque")
					{
						//Reset level to its initial value
						if(nextplaque.level==0 && nextplaque.waterlevel > 0)
							nextplaque.level = nextplaque.waterlevel;
						//Reset message to its initial value
						self.message=self.no_puzzle_msg;
					}
					else
					{
						plaque_draw(MSG_ONE,0);
					}
					self = nextplaque;
					self.inactive = FALSE;
					if(self.use)
						self.use();
					return;
				}
			}
		}
	}
		
	if ((other.classname == "player") && (!other.plaqueflg))
	{
		if (self.spawnflags & 8)
		{
			if (other != self.oldenemy)
			{
				self.oldenemy = other;
				self.lifetime = time + 1;
				self.attack_state (+) 1;
			}
			else
			{
				if (self.lifetime < time)
				{
					self.oldenemy = self;
					self.attack_state (-) 1;
				}
				else
					self.lifetime = time + 1;
			}
		}

		if(!self.spawnflags&4)
		{
			makevectors (other.v_angle);
			spot1 = other.origin + other.view_ofs;
			if (self.spawnflags & 8) //Inky 20210105 Not solid don't have to be necessarily No LoS
			{
				spot2 = (self.absmax+self.absmin)*0.5 - spot1;
				if (normalize(v_forward) * normalize(spot2) < 0.5)
					return;		// not facing the right way
			}
			else
			{
				spot2 = spot1 + (v_forward*25); // Look just a little ahead
				traceline (spot1, spot2 , FALSE, other);

				if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
				{
					traceline (spot1, spot2 - (v_up * 30), FALSE, other);  // 30 down
				
					if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
					{
						traceline (spot1, spot2 + v_up * 30, FALSE, other);  // 30 up
					
						if ((trace_fraction == 1.0) || (trace_ent.classname!="plaque"))
							return;
					}
				}
			}
		}

		other.plaqueflg = 1;
		other.plaqueangle = other.v_angle;
		msg_entity = other;
	 	plaque_draw(MSG_ONE,self.message);

		if (self.attack_state & 1)
			return;

		if (other.noise1 != "")
  			sound (other, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
		else 
			sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	}
}

/*QUAKED plaque (.5 .5 .5) ? INVISIBLE deactivated no_line_of_sight not_solid

A plaque on the wall a player can read
-------------------------FIELDS-------------------------

"message" the index of the string in the text file

"noise1" the wav file activated when plaque is used

deactivated - if this is on, the plaque will not be readable until a trigger has activated it.
no_line_of_sight - you don't have to be actually LOOKING at the plaque to have the message come up
--------------------------------------------------------
*/
void() plaque_die = { plaque_draw(MSG_ONE,0);remove(self); }

void() plaque =
{
	setsize (self, self.mins, self.maxs);
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	
	if (self.spawnflags & 8)
		self.solid = SOLID_TRIGGER;
	else
		self.solid = SOLID_SLIDEBOX;

	if (deathmatch)  // I don't do a remove because they might be a part of the architecture
		return;

	self.use = plaque_use;
	self.th_die = plaque_die;

	//Inky 20200703 backup the initial value of self.message to be able to come back later
	self.no_puzzle_msg=self.message;
	
	//Inky 20200624 Trigger behavior
	if(!self.wait)
		self.wait = -1;
	
	precache_sound("raven/use_plaq.wav");
	self.noise = "raven/use_plaq.wav";

	self.touch = plaque_touch;

	if (self.spawnflags & PLAQUE_INVISIBLE)
		self.effects (+) EF_NODRAW;

	if (self.spawnflags & PLAQUE_ACTIVATE)
		self.inactive = 1;
	else
		self.inactive = 0;
};

