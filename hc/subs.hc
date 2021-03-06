/*
 * $Header: /H2 Mission Pack/HCode/SUBS.hc 21    3/14/98 6:37p Mgummelt $
 */
float SPAWNFLAG_ACTIVATED	= 8;



void SUB_Null() {}

void SUB_Remove() {stopSound(self,0); remove(self); }

void obj_barrel_explode (void);	//ref from barrel.hc

/*
void spawntestmarker(vector org, float life, float skincolor)
{
	newmis=spawn_temp();
	newmis.drawflags=MLS_ABSLIGHT;
	newmis.abslight=1;
	newmis.frame=1;
	newmis.skin=skincolor;
	setmodel(newmis,"models/test.mdl");
	setorigin(newmis,org);
	newmis.think=SUB_Remove;
	if(life==-1)
		self.nextthink=-1;
	else
		thinktime newmis : life;
}*/


/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void SetMovedir()
{
	if(self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if(self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else 
	{
		makevectors(self.angles);
		self.movedir = v_forward;
		//Have to do this to correct for floating point optimizations
		if(fabs(self.movedir_x)<0.001)
			self.movedir_x=0;
		if(fabs(self.movedir_y)<0.001)
			self.movedir_y=0;
		if(fabs(self.movedir_z)<0.001)
			self.movedir_z=0;
	}
	
	self.angles = '0 0 0';
}


/*
 * InitTrigger() -- Sets up the entity fields for a trigger.
 *                  If .angles is set, it is used for a one-way touch.
 *                  Use a yaw of 360 if you want a 0-degree one-way touch.
 */

void InitTrigger()
{
	if(self.angles != '0 0 0')
		SetMovedir();
	setmodel(self, self.model);       // set size and link into world
	self.solid		= SOLID_TRIGGER;
	self.movetype	= MOVETYPE_NONE;
	self.modelindex = 0;
	self.model		= "";
	if(self.spawnflags & SPAWNFLAG_ACTIVATED)
		self.inactive=TRUE;
}


/*
 * SUB_CalcMove() -- Calculates self.velocity and self.nextthink to reach
 *                   dest from self.origin traveling at speed.
 */

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
vector vdestdelta;
float  len, traveltime;

	if(!tspeed)
		objerror("No speed is defined!");

	self.think1		= func;
	self.finaldest	= tdest;
	self.think		= SUB_CalcMoveDone;

	if(tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	vdestdelta = tdest - self.origin;	// set destdelta to the vector needed to move
	len = vlen(vdestdelta); 			// calculate length of vector
	traveltime = len / tspeed;			// divide by speed to get time to reach dest

	if(traveltime < 0.1)
	{
		self.velocity  = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// hcc won't take vec/float	
};


/*
 * SUB_CalcMoveEnt() -- Does the same as above, but takes a specific entity.
 */
/*
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
	local entity stemp;

	stemp	= self;
	self	= ent;
	SUB_CalcMove(tdest, tspeed, func);
	self	= stemp;
};
*/

/*
 * SUB_CalcMoveDone -- Sets origin to the exact destination after moving.
 */

void SUB_CalcMoveDone()
{
	setorigin(self, self.finaldest);
	if(self.wait!=0||self.enemy.classname!="path_corner")
	{
		self.velocity = '0 0 0';
		self.nextthink = -1;
	}
	else
		thinktime self : 99999999;
	if(self.think1)
		self.think1();
}


/*
 * SUB_CalcAngleMove() -- Calculates self.avelocity and self.nextthink to
 *                        rotate to destangle from self.angles.
 *                        The caller should make sure self.think is valid.
 */

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
vector destdelta;
float  len, traveltime;

	if(!tspeed)
		objerror("SUB_CalcAngleMove: No speed defined!");

	destdelta = destangle - self.angles;	// set destdelta to the vector needed to move
	len = vlen(destdelta);					// calculate length of vector
	traveltime = len / tspeed;				// divide by speed to get time to reach dest

// set nextthink to trigger a think when dest is reached
	self.nextthink	= self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity	= destdelta * (1 / traveltime);

	self.think1		= func;
	self.finalangle = destangle;
	self.think		= SUB_CalcAngleMoveDone;
};


/*
 * SUB_CalcAngleMoveEnt() -- Does the same as above, but takes a specific entity.
 */
/*
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
	local entity stemp;

	stemp	= self;
	self	= ent;
	SUB_CalcAngleMove(destangle, tspeed, func);
	self	= stemp;
};
*/

/*
 * SUB_CalcAngleMoveDone() -- After rotating, set .angle to exact final angle.
 */

void SUB_CalcAngleMoveDone()
{
//	dprint("Done rotating\n");
	self.angles = self.finalangle;
	if(self.wait!=0||self.enemy.classname!="path_corner")
	{
		self.avelocity = '0 0 0';
		self.nextthink = -1;
	}
	else
		thinktime self : 99999999;
	if (self.think1)
		self.think1();
}

/*
 * SUB_CalcMoveAndAngleDone-Set angle and position in final states.
 */

void SUB_CalcMoveAndAngleDone(void)
{
//	dprint("Angle and move done\n");
	setorigin(self, self.finaldest);
	self.angles = self.finalangle;
	if(self.wait!=0||self.enemy.classname!="path_corner")
	{
		self.velocity = self.avelocity = '0 0 0';
		self.nextthink = -1;
	}
	else
		thinktime self : 99999999;
	if (self.think1!=SUB_Null)
	{
//		dprint("Going to next func\n");
		self.think1();
	}
//	else
//		dprint("No next func\n");
}

void()SUB_CalcAngleOnlyDone;

void SUB_CalcMoveOnlyDone(void)
{
//	dprint("Move done\n");
	setorigin(self, self.finaldest);
	if(self.wait!=0||self.enemy.classname!="path_corner")
		self.velocity = '0 0 0';
	self.movetime=0;
	if(self.angletime>0.01)//1/5th of a frame
	{
		self.think=SUB_CalcAngleOnlyDone;
		self.nextthink=self.ltime+self.angletime;
//		dprintf("ETA - %s\n",self.nextthink - self.ltime);
	}
	else
		SUB_CalcMoveAndAngleDone();
}

void SUB_CalcAngleOnlyDone(void)
{
//	dprint("Angle done\n");
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.angletime = 0;
	if(self.movetime>0.01)//1/5th of a frame
	{
		self.think=SUB_CalcMoveOnlyDone;
		self.nextthink=self.ltime+self.movetime;//was 0.0000002384, and would not think
//		dprintf("Movetime*1000000000 - %s\n",self.movetime*1000000000);
//		dprintf("ETA - %s\n",(self.nextthink - self.ltime));
//		dprintf("Ltime - %s\n",self.ltime);
//		dprintf("Nextthink - %s\n",self.nextthink);
	}
	else
		SUB_CalcMoveAndAngleDone();
}

/*
====================================================================
SUB_CalcMoveAndAngle()
MG!!!

Calculates self.velocity and self.nextthink to reach dest from
self.origin traveling at speed, does same with angle simultaneously.
====================================================================
*/

void SUB_CalcMoveAndAngle (float synchronize)
{
vector vdestdelta, destdelta;
float  len, alen;
//MOVE
	if(!self.speed)
		objerror("No speed is defined!");

	if(self.finaldest == self.origin)
	{
		self.velocity = '0 0 0';
		self.movetime = 0;
	}
	else
	{
		vdestdelta = self.finaldest - self.origin;	// set destdelta to the vector needed to move
		len = vlen(vdestdelta); 			// calculate length of vector
		self.movetime = len / self.speed;			// divide by speed to get time to reach dest

		if(self.movetime < 0.1)
		{
			self.velocity  = '0 0 0';
			self.movetime = 0.1;
		}
		// scale the destdelta vector by the time spent traveling to get velocity
		self.velocity = vdestdelta * (1/self.movetime);	// hcc won't take vec/float	
	}


//ANGLE

	if(self.angles==self.finalangle)
	{	
			self.avelocity = '0 0 0';
			self.angletime = 0;
	}
	else
	{
		destdelta = self.finalangle - self.angles;	// set destdelta to the vector needed to move
		alen = vlen(destdelta);					// calculate length of vector
		if(!synchronize)
		{
			if(!self.anglespeed)
				objerror("SUB_CalcAngleMove: No speed defined!");
		}
		else
			self.anglespeed=self.speed/len*alen;				//
		self.angletime = alen / self.anglespeed;				// divide by speed to get time to reach dest
// scale the destdelta vector by the time spent traveling to get velocity
		self.avelocity	= destdelta * (1 / self.angletime);
	}
//	if(synchronize&&self.angletime!=self.movetime)
//		dprint("Whoops!\n");


// set nextthink to trigger a think when dest is reached

	if(self.movetime<=0)
		self.movetime=self.angletime;
	if(self.angletime<=0)
		self.angletime=self.movetime;

	if(self.movetime>self.angletime)
	{
		self.movetime-=self.angletime;
		self.think = SUB_CalcAngleOnlyDone;
		self.nextthink=self.ltime+self.angletime;
//		dprintf("1: ETA - %s\n",self.nextthink - self.ltime);
	}
	else if(self.movetime<self.angletime)
	{
		self.angletime-=self.movetime;
		self.think = SUB_CalcMoveOnlyDone;
		self.nextthink=self.ltime+self.movetime;
//		dprintf("2: ETA - %s\n",self.nextthink - self.ltime);
	}
	else
	{
		self.think = SUB_CalcMoveAndAngleDone;
		self.nextthink=self.ltime+self.movetime;
//		dprintf("3: ETA - %s\n",self.nextthink - self.ltime);
	}
}


/*
 * SUB_CalcMoveAndAngleInit-Set movement values and call main function
 */
void(vector tdest, float tspeed, vector destangle, float aspeed,void() func,float synchronize) SUB_CalcMoveAndAngleInit =
{
	self.finaldest = tdest;
	self.speed = tspeed;
	self.finalangle = destangle;
	self.anglespeed = aspeed;
	self.think1 = func;
//	if(self.think1==SUB_Null)
//		dprint("No next func!\n");
	SUB_CalcMoveAndAngle(synchronize);
};

/*
 * DelayThink()
 */

void DelayThink()
{
	activator = self.enemy;
	if(self.level)
		self.check_ok=self.owner.check_ok=TRUE;
	SUB_UseTargets();
	self.check_ok=self.owner.check_ok=FALSE;
	remove(self);
}


/*
 * SUB_UseTargets() --
 *
 * The global "activator" should be set to the entity that initiated the firing.
 *
 * If self.delay is set, a DelayedUse entity will be created that will actually
 * do the SUB_UseTargets after that many seconds have passed.
 *
 * Centerprints any self.message to the activator.
 *
 * Removes all entities with a targetname that match self.killtarget,
 * and removes them, so some events can remove other triggers.
 *
 * Search for (string)targetname in all entities that
 * match (string)self.target and call their .use function
 */

void SUB_UseTargets()
{
entity t, stemp, otemp, act, msg_receiver;
string s;

//
// check for a delay
//
	if(self.delay)
	{
		// create a temp object to fire at a later time
//		dprint(activator.classname);
//		dprint(" using something with a delay\n");
		t = spawn();
		t.netname = "DelayedUse";
		t.classname = self.classname;
		t.owner = self;
		thinktime t : self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		t.failtarget = self.failtarget;
		t.close_target = self.close_target;
		t.nexttarget = self.nexttarget;
		t.style = self.style;
		t.mangle = self.mangle;
		t.frags = self.frags;
		t.use=self.use;
		t.inactive=self.inactive;
		if(self.check_ok)
			t.level=TRUE;
		return;
	}

	//Inky 20201105
	if(activator.classname == "player")
		msg_receiver = activator;
	else if(self.skin==1 && (self.msg3 != "" || self.message != 0))
		msg_receiver = find(world,classname,"player");
	else
		msg_receiver = world;
	
	//Inky 20200707 Flash
	if(self.msg3 != "" && (activator.classname == "player" || self.skin == 1))
	{
		stuffcmd(msg_receiver, self.msg3);
	}
//
// print the message //Inky 20200831 Allow printing a message to the player even if they're not the activator, provided the trigger has skin 1
//
	if(self.message != 0 && (activator.classname == "player"||self.skin==1))
	{
		s = getstring(self.message);
		centerprint (msg_receiver, s);
		if(!self.noise)
			sound (msg_receiver, CHAN_VOICE, "misc/comm.wav", 1, ATTN_NORM);
	}
//
// kill the killtargets
//
	if(self.killtarget && self.killtarget != "")
	{
		t = world;
		do
		{
			t = find(t, targetname, self.killtarget);
			if(t!=world)
			{
				if(self.classname=="func_train" || self.classname=="func_train_mp")
				{//Trains can't target things when they die, so use killtarget
					if(t.th_die)
					{
						if(t.th_die==obj_barrel_explode)
							t.think=t.use;
						else
							t.think=t.th_die;
						thinktime t : .01;
						t.targetname="";
					}
					else if(t.health)
					{
						t.think=chunk_death;
						thinktime t : .01;
						t.targetname="";
					}
					else
						remove(t);
				}
				else
				{
					if(t.switchshadstyle) lightstyle(t.switchshadstyle, "m"); /*20210703 bmFbr's shadows code*/
					
					//Inky 20201126 Allow a killtargeted thing to leave nicely instead of just lamely vanishing
					if (t.dmg_take)
					{
						stemp = self;
						self = t;
						
						if(t.th_die)
						{
							if(t.th_die==obj_barrel_explode)
								t.use();
							else
								t.th_die();
						}
						else if(t.health)
						{
							t.th_die=chunk_death;
							t.th_die();
						}
						else
							remove(t);

						self = stemp;
					}
					else
					{
						if(t.movechain) remove(t.movechain);
						remove(t);
					}
				}
			}
		}
		while(t!=world);
	}

//
// fire targets
//
	self.style=0;
	if (self.target && self.target != "")
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				if(self.nexttarget!=""&&self.target!=self.nexttarget)
					if(self.netname=="DelayedUse")
						self.owner.target=self.nexttarget;
					else
						self.target=self.nexttarget;
				return;
			}
			if(t.style>=32&&t.style!=self.style)
			{
				self.style=t.style;
				if(self.classname=="breakable_brush")
				{
					lightstylestatic(self.style,0);
					stopSound(self,CHAN_BODY);
					//sound(self,CHAN_BODY, "misc/null.wav", 0.5, ATTN_STATIC);
				}
				else
					lightstyle_change(t);
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			//Inky: replaced the "toggle only" code below by the 2 first ifs
			/*
			if (other.classname == "trigger_activate")
				if (!self.inactive) 
					self.inactive = TRUE;
				else
					self.inactive = FALSE;
			*/
			if (other.classname == "trigger_activate" && other.spawnflags & 64) //64 = SPAWNFLAG_NO_TOGGLE
			{
				self.inactive = FALSE;
			}
			else if (other.classname == "trigger_activate")
				if (!self.inactive) 
					self.inactive = TRUE;
				else
					self.inactive = FALSE;
			else if (other.classname == "trigger_deactivate")
				self.inactive = TRUE;
			else if (other.classname == "trigger_combination_assign"&& self.classname=="trigger_counter")
				self.mangle = other.mangle;
			else if (other.classname == "trigger_counter_reset"&& self.classname=="trigger_counter")
			{
				self.cnt = 1;
				self.count = self.frags;
				self.items = 0;
			}
			else if (self.use != SUB_Null&&(self.inactive==FALSE || self.classname=="plaque")) //Inky 20200704 .use was invoked only if self was active but for a plaque use is precisely there to activate!
			{	//Else here because above trigger types should not use it's target
//				if(self.classname=="obj_talkinghead"&&self.think!=talkhead_idle)
//					dprint("Already talking, please wait!\n");
//				else 
				if (self.use)
				{
/*					if(self.classname=="trigger_changelevel")
					{
						dprint(stemp.classname);
						dprint(" firing ");
						dprint(self.classname);
						dprint(" target: ");
						dprint(self.targetname);
						dprint("\n");
					}
*/					self.use ();
				}
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while (1);
	}
}


/*
 * SUB_AttackFinished() -- Gets ready to finish the attack.  In Nightmare
 *                         mode, all attack_finished times become 0, and
 *                         some monsters refire twice automatically.
 */

void SUB_AttackFinished(float normal)
{
	self.cnt = 0;		// refire count for nightmare
	if(skill != 3)
		self.attack_finished = time + normal;
}


/*
 * SUB_CheckRefire() -- Decides whether or not for monster to refire.
 */
/*
float visible(entity targ);

void (void() thinkst) SUB_CheckRefire =
{
	if(skill != 3)
		return;
	if(self.cnt == 1)
		return;
	if(!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};
*/

