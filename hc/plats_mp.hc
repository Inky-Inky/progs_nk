void() train_next_mp;
void() func_train_find_mp;

float MODEL_AND_BRUSH = 65536;
float PLAYER_MODEL = 262144;

void() train_blocked_mp =
{
//	dprint("train blocked\n");
	if (time < self.attack_finished) return;
		self.attack_finished = time + 0.5;

	if(self.dmg==-1&&self.anglespeed>0)
	{
	float on_top,in_front,to_right,other_dist;
	vector avel, other_dir, throw_dir;
		avel = normalize(self.avelocity);
		makevectors(self.angles);
		other_dir = normalize(other.origin-self.origin);
		other_dist = vlen(other.origin - self.origin);
		if(v_forward*other_dir>0)//in front
			in_front=TRUE;
		if(v_right*other_dir>0)//to right
			to_right=TRUE;
		if(v_up*other_dir>0)//on top
			on_top=TRUE;

		if(avel_x>0)//pitch
			if(on_top)
				throw_dir_z+=self.anglespeed;
			else
				throw_dir_z+=self.anglespeed*-1;
		if(avel_y>0)//yaw
			if(in_front)
				throw_dir+=v_right*self.anglespeed;
			else
				throw_dir+=v_right*self.anglespeed*-1;
		if(avel_z>0)//roll
			if(!to_right)
				throw_dir_z+=self.anglespeed;
			else
				throw_dir_z+=self.anglespeed*-1;

		other.velocity=throw_dir;
		other.flags(-)FL_ONGROUND;
	}
	else
		T_Damage (other, self, self, self.dmg);
};

void() train_use_mp =
{
	if(self.movechain.model=="models/soulskul.mdl")
	{//Hack to make Jeremy happy
		self.weaponmodel="";
		self.movechain.think=rider_die;
		thinktime self.movechain : 0.1;
	}

	if(self.wait==-1)
		self.use=SUB_Null;

	if (self.spawnflags & TRAIN_GLOW)
	{
		self.effects = EF_BRIGHTLIGHT;
	}

	if (self.decap != 1) 
	{ //Moving?
		self.decap = 1;
		if (self.think != train_next_mp)
		{ 
//			dprintf("Train wait %s first used by",self.wait);
//			dprint(other.classname);
//			dprint("\n");
			self.think = func_train_find_mp;
			train_next_mp();
		}
	}
	else 
	{
		if (self.spawnflags & TRAIN_RETURN)
			self.decap = 0;
		else
		{
//			dprintf("Train wait %s used whilst moving by ",self.wait);
//			dprint(other.classname);
//			dprint("\n");
			self.decap = 2;
		}
	}
};

void() train_wait_mp =
{
	//Check to make sure train is active
	//dprintf("wait func- my wait is :%s\n",self.wait);

	//Trigger the target associated (through close_target) to the path_corner being reached 
	if(self.close_target)
	{
		string oldtarget = self.target;
		string oldkilltarget = self.killtarget;
		self.target = self.close_target;
		self.killtarget = string_null;
		activator = other = self;
		SUB_UseTargets();
		self.target = oldtarget;
		self.killtarget = oldkilltarget;
	}
	
	if(self.decap!=2)
	{
		//dprint("Train not 2 decap\n");
		self.think = train_next_mp;
		if(self.wait==-2)
		{
			//dprint("Train breaking\n");
			stopSound(self,CHAN_VOICE);
			//sound (self, CHAN_VOICE, "misc/null.wav", 1, ATTN_NONE);
			//dprint("Train wait of -2\n");
			if(self.th_die)
			{
				if(self.pausetime)
				{
					self.think=self.th_die;
					self.nextthink=self.ltime+self.pausetime;
				}
				else
				{
					self.th_die();
					return;
				}
			}
			else
			{
				if(self.pausetime)
				{
					self.think=chunk_death;
					self.nextthink=self.ltime+self.pausetime;
				}
				else
				{
					chunk_death();
					return;
				}
			}
		}
		else if(self.wait==-1||self.wait==-3)
		{
			//dprint("Train wait of -1 or -3\n");
			if(self.level)
				sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
			else
				sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
			self.nextthink=-1;
		}
		else if (self.wait)
		{
			if(self.level)
				sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
			else
				sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
			self.nextthink = self.ltime + self.wait;
			//dprintf("Next think: %s\n",self.nextthink);
			//dprintf("Time: %s\n",time);
		}
		else
		{
			self.nextthink = self.ltime + 0.1;
			//dprint("Train no wait\n");
		}
	}	
	else
	{
		if(self.level)
			sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
		else
			sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}

	if (self.decap == 0 || self.decap == 2) 
		if(!self.effects&EF_NODRAW)
			self.effects = 0;
		else
			self.effects=EF_NODRAW;
};

void() train_rotate_mp =
{
entity targ;
vector dir;

	targ = self.enemy;

	if (targ.mangle_x != 0 || targ.mangle_y != 0 || targ.mangle_z != 0)
	{
		dir = self.angles;
		dir += targ.mangle;

		if(self.wait)
			SUB_CalcAngleMove (dir, self.anglespeed, train_wait_mp);
		else
			SUB_CalcAngleMove (dir, self.anglespeed, train_next_mp);
	}
	else if(self.wait)
		train_wait_mp();
	else
		train_next_mp();
};

void(entity train, entity targ) func_train_setup_animation;

void() func_train_animate = {
	self.nextthink = time + fabs(self.speed);
    self.frame = self.frame + sign(self.speed);
	
	if (self.enemy.spawnflags & /*Anim back & forth*/4 && self.frame < self.button1)
	{
		self.speed = -1 * self.speed;
		self.frame+=2;
	}
	else if (self.enemy.spawnflags & /*Anim back & forth*/4 && self.frame > self.button2)
	{
		self.speed = -1 * self.speed;
		self.frame-=2;
	}
	else
		self.frame = wrap(self.frame, self.button1, self.button2);
	
	//Inky 20211015 Play the animation only once then jump in advance to the next path corner's animation
	if(self.frame==self.button2 && self.button2!=self.button1 && self.enemy.spawnflags & /*Continue on next anim*/2)
	{
		entity nextpc = find(world,targetname,self.enemy.target);
		if(nextpc) func_train_setup_animation(self.owner,nextpc);
	}
};

//Inky 20201109 Attitudes below this constant take the carried weapon into consideration, above don't.
float PLAYER_ANIM_JUMP   = 6;

//Inky 20201105 Animates the train model according to its destination path_corner's settings if any (animates only if targ.modelindex or targ.button2 are set)
void(entity train, entity targ) func_train_setup_animation = {
	float weapmod;

	if ((train.spawnflags&PLAYER_MODEL && targ.modelindex) || (train.weaponmodel && targ.button2))
	{
		//Set the target's animation boundaries automatically for the desired model attitude
		if (targ.modelindex)
		{
			if(targ.modelindex<PLAYER_ANIM_JUMP||(player.playerclass==CLASS_NECROMANCER&&targ.modelindex<=PLAYER_ANIM_JUMP))
			{
				if(player.weapon==IT_WEAPON4)
					weapmod=3;
				else if(player.weapon==IT_WEAPON3)
					weapmod=2;
				else if(player.weapon==IT_WEAPON2)
					weapmod=1;
				else if(player.weapon==IT_WEAPON1)
					weapmod=0;
			}
			else
				weapmod=0;

			targ.button1 = player_start_frames [(player.playerclass - 1) * 4 + (targ.modelindex - 1)*20 + weapmod];
			targ.button2 = player_end_frames   [(player.playerclass - 1) * 4 + (targ.modelindex - 1)*20 + weapmod];
			targ.frags = 0.1;
		}
		
		//Get animation boundaries from target setup
		train.movechain.button1 = targ.button1;
		train.movechain.button2 = targ.button2;
		
		//Set the initial animation frame
		if (targ.button0)
			train.movechain.frame = targ.button0;
		else
			train.movechain.frame = targ.button1;
		
		//Set the animation speed
		if (targ.frags)
			train.movechain.speed = targ.frags;
		else
			train.movechain.speed = 0.05; // Default animation speed

		//Initiate the animation
		train.movechain.enemy = targ; //Inky 20211015 To help the "Continue on next anim" feature
		train.movechain.nextthink = time + train.movechain.speed;
		train.movechain.think = func_train_animate;
	}
};

void() train_next_mp =
{//NOTE!!! WHEN A TRAIN HAS A WAIT <= TIME, IT STOPS!!!
entity	oldtarg,targ;
vector  dir,end_spot;
vector	slope_angles;
/*	if(self.movechain)
	{
		dprint(self.movechain.model);
		dprint(" moving\n");
	}
*/
//float targ_aspeed;//,targ_speed;

/*
	dprint("Next target: ");
	dprint(self.target);
	dprint("\n");
*/
	
	//Trigger the target associated (through close_target) to the path_corner being reached 
	if(self.close_target)
	{
		string oldtarget = self.target;
		string oldkilltarget = self.killtarget;
		self.target = self.close_target;
		self.killtarget = string_null;
		activator = other = self;
		SUB_UseTargets();
		self.target = oldtarget;
		self.killtarget = oldkilltarget;
	}
	
	targ = find (world, targetname, self.target);
	self.target = targ.target;
	self.close_target = targ.close_target;

	if (!self.decap && self.spawnflags & TRAIN_RETURN) 
		if (self.noise3 == targ.targetname) 
			 self.decap = 2;

	if (!self.target)
		objerror ("train_next: no next target");
//	else
//		dprint("Found next target\n");

	if (targ.wait)
		self.wait = targ.wait;
//	if(self.wait)
//		dprintf("My wait is: %s\n",self.wait);

//	else
//		self.wait = 0;
	
	oldtarg=self.enemy;
	self.enemy = targ;

	if(self.level==0)
		sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	else if(self.level==1)
		sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, self.noise1, 1, self.level);
	
/*Used to not set self speed to targ speed
	if(targ.speed)
		targ_speed=targ.speed;
	else
		targ_speed = self.speed;
*/
	if(targ.speed)
		self.speed=targ.speed;

//	dprintf("Train's speed now: %s\n",targ_speed);

	if(self.spawnflags&SLOPE)
	{
//		dprint("Train auto-sloping\n");
//Make everything 0 - 359
		while(self.angles_x>359)
			self.angles_x -= 360;
		while(self.angles_x<0)
			self.angles_x += 360;
//		while(self.angles_y>359)
//			self.angles_y -= 360;
//		while(self.angles_y<0)
//			self.angles_y += 360;

		slope_angles = vectoangles(normalize(targ.origin - self.origin));

		while(slope_angles_x>359)
			slope_angles_x -= 360;
		while(slope_angles_x<0)
			slope_angles_x += 360;
//		while(slope_angles_y>359)
//			slope_angles_y -= 360;
//		while(slope_angles_y<0)
//			slope_angles_y += 360;

		targ.mangle_x = self.angles_x - slope_angles_x;
//		targ.mangle_y = self.angles_y - slope_angles_y;

//		if(targ.mangle_x<-180)
//			targ.mangle_x+=360;
//		else if(targ.mangle_x>180)
//			targ.mangle_x-=360;
//		if(targ.mangle_y<-180)
//			targ.mangle_y+=360;
//		else if(targ.mangle_y>180)
//			targ.mangle_y-=360;

/*
Don't mod roll
		if(targ.mangle_z>180)
			targ.mangle_z= (180 - (targ.mangle_z - 180))*-1;
		else if(targ.mangle_z<-180)
			targ.mangle_z= 180 - (targ.mangle_z + 180);
*/
//		dprintv("Target mangle: %s\n",targ.mangle);
	}

	//Inky 20201105 Animates the train model according to the destination path_corner's settings (if any: animates only if given a frame range thanks to self.button2)
	func_train_setup_animation(self,targ);
	
	if(self.spawnflags&USE_ORIGIN&&self.origin!='0 0 0')
		end_spot = targ.origin;
	else
		end_spot = targ.origin - self.mins;

	if (!self.spawnflags&ANGLE_WAIT&&(targ.mangle_x != 0 || targ.mangle_y != 0 || targ.mangle_z != 0))
	{
		dir = self.angles;
		dir += targ.mangle;

//		dprint ("move and rotate\n");
		if(targ.anglespeed)
			self.anglespeed=targ.anglespeed;

		if(targ.spawnflags&SYNCH||self.spawnflags&SLOPE)
		{
			if(!self.wait)
				SUB_CalcMoveAndAngleInit (end_spot, self.speed, dir, self.anglespeed, train_next_mp,TRUE);
			else
				SUB_CalcMoveAndAngleInit (end_spot, self.speed, dir, self.anglespeed, train_wait_mp,TRUE);
		}
		else
		{
			if(!self.wait)
				SUB_CalcMoveAndAngleInit (end_spot, self.speed, dir, self.anglespeed, train_next_mp,FALSE);
			else
				SUB_CalcMoveAndAngleInit (end_spot, self.speed, dir, self.anglespeed, train_wait_mp,FALSE);
		}
	}
	else
	{
		
		if(targ.mangle_x != 0 || targ.mangle_y != 0 || targ.mangle_z != 0)
		{
//			dprint ("move then rotate\n");
			SUB_CalcMove (end_spot, self.speed, train_rotate_mp);
		}
		else
		{
//			dprintv("move- no rotate %s\n",targ.mangle);

			if(!self.wait)
				SUB_CalcMove (end_spot, self.speed, train_next_mp);
			else
				SUB_CalcMove (end_spot, self.speed, train_wait_mp);
		}
	}

	if (self.spawnflags & TRAIN_WAITTRIG)
		self.decap = 2;
};

void() func_train_find_mp =
{
entity	targ;

	targ = find (world, targetname, self.target);
	self.enemy=targ;
	self.target = targ.target;
	if(self.spawnflags&USE_ORIGIN&&self.origin!='0 0 0')
		setorigin (self, targ.origin);
	else
		setorigin (self, targ.origin - self.mins);

	if(targ.mangle_x)
	{
//		dprint("taking path's x\n");
		self.angles_x = targ.mangle_x;
	}
	if(targ.mangle_y)
	{
//		dprint("taking path's y\n");
		self.angles_y = targ.mangle_y;
	}
	if(targ.mangle_z)
	{
//		dprint("taking path's z\n");
		self.angles_z = targ.mangle_z;
	}

	if (!self.targetname)
	{	// not triggered, so start immediately
		self.decap = 1;
		self.nextthink = self.ltime + 0.1;
		self.think = train_next_mp;
	}
	
	//Inky 20201105 Animates the train model according to the destination path_corner's settings (if any: animates only if given a frame range thanks to self.button2)
	func_train_setup_animation(self,targ);
};

void() liquid_touch;

/*QUAKED func_train_mp (0 .5 .8) ? invisible TOGGLE RETURN TRANSLUCENT SLOPE ANGLEMATCH USE_ORIGIN ANGLEWAIT
Hexen 2 MISSION PACK version Trains

Remember: angles and mangles are 'x y z' format where x = pitch, y = yaw and z = roll

Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
soundtype
0) none
1) ratchet metal
2) pullies
3) sliding
4) normal?
5) medival?
6) guillotine?
7) chain?
8) Rolling boulder
9) Spinning prayer wheel

if train is only moving to one spot
"angle"    - to tell it's direction
"distance" - in pixels, how far to move
"speed" - how fast it moves between spots (default=100)
"anglespeed" - how fast it rotates to a new angle (default = 100)
"wait" - -1 will make it stop forever, -2 will make it blow up (you can put the waits on the pathcorners and it will take the wait from there.
		-3 will make the train stop and wait for the next trigger event (don't blame me!- Blame Josh!)
NOTE: If you give it a wait of -2, be sure to set the thingtype.

"pausetime" - How long to wait after getting to the end of it's path before blowing up, default is 0

"weaponmodel" - A model file to use instead of train visuals, but will have the blocking shape of the train you make
WARNING: use "directory/model.mdl" format- NOT a "\"!!!
NOTE:  You should use a origin brush in the train and make sure you know where the origin of the model you're using is at.
if set to "models/null.spr", it will effectively make an invisible train.

thingtype - type of chunks and sprites it will generate
    0 - glass
    1 - grey stone (default for trains)
    2 - wood
    3 - metal
    4 - flesh 
    5 - fire
    6 - clay
    7 - leaves
    8 - hay
    9 - brown stone
   10 - cloth
   11 - wood & leaf
   12 - wood & metal
   13 - wood stone
   14 - metal stone
   15 - metal cloth
   16 - spider web
   17 - stained glass
   18 - ice
   19 - clear glass
   20 - red glass

The train will modify it's angles by whatever angles it's next path point has, so if it heads towards a path corner with an angle of '0 90 0', the train will rotate '0 90 0' on it's way to the pathpoint.  If you make the anglespeed the same as the angle, the turn should finish right as the train gets to the new spot.

NOTE: A path_corner using spawnflag "SYNCH" will make the train automatically calculate a new anglespeed based on the distance it's going and will finish the turn at the same time the move is done.

As usual, any rotating brush needs an origin brush.

"abslight" - to set the absolute light level
"angles" - only used for models attached to trains.
"level" - if set to "1" sounds from train have no attenuation (can always be heard no matter how far player is away)

if "invisible" is checked, train will be invisible and not solid
SLOPE - Train will automatically find the pitch and yaw it needs to get from path_corner to path_corner
ANGLEMATCH - If it has an attached model, that model's angles will change with the train's
USE_ORIGIN - Use an origin brush as origin for moving along path, not south-west-bottom corner.
ANGLE_WAIT - Train will not change angles until it reached path_corner, and will not move again until that angle movement is done
MODEL_AND_BRUSH - Trains with weaponmodel set keep their brushes drawn as well
PLAYER_MODEL - weaponmodel is automatically set to the relevant player model depending on the current class

self.decap:
0 - Initial state when spawned or "returned" (used for the second time -first time being the train activation- with spawnflags & TRAIN_RETURN 'Return')
1 - Moving
2 - Stopped (like spawnflags & TRAIN_WAITTRIG 'Toggle')
Not so clear what difference is self.decap==0 versus self.decap==2 (train seems able to be fired again in both cases)
If spawnflags & TRAIN_RETURN 'Return', seems the train can be returned specifically to one of its path_corners and not just the next one thanks to its netname being the pc's targetname

Animation
---------
Train must have a weaponmodel + the following special settings at each path_corner meant to be reached with an animation:
"button0" - starting frame # within the range, if different from the first animation frame (optional)
"button1" - first animation frame (mandatory)
"button2" - last animation frame (mandatory)
"frags" - frame duration, if different from the default 0.05 (optional)
*/
void() func_train_mp =
{
entity targ; float useOldPrecache;

	if(!world.spawnflags&MISSIONPACK)
	{
		func_train();
		return;
	}

	if(self.dmg==666)
		if(mapname=="tibet9")
			self.dmg=50;

	self.decap = 0;

	if (self.spawnflags & TRAIN_GLOW) 
	{
		self.solid=SOLID_NOT;
		self.effects(+)EF_NODRAW;
	}
	else 
	{
		self.solid = SOLID_BSP;
		setmodel (self, self.model);
		//Inky 20201109 PLAYER_MODEL support
		if(self.spawnflags&PLAYER_MODEL)
		{
			if(cl_playerclass==CLASS_PALADIN)
				self.weaponmodel = "models/paladin.mdl";
			else if(cl_playerclass==CLASS_CRUSADER)
				self.weaponmodel = "models/crusader.mdl";
			else if(cl_playerclass==CLASS_NECROMANCER)
				self.weaponmodel = "models/necro.mdl";
			else if(cl_playerclass==CLASS_ASSASSIN)
				self.weaponmodel = "models/assassin.mdl";
			else if(cl_playerclass==CLASS_SUCCUBUS)
				self.weaponmodel = "models/succubus.mdl";
		}
		if(self.weaponmodel)
		{
			self.movechain=spawn();
			self.movechain.owner=self;
			if(self.headmodel) self.movechain.targetname=self.headmodel;
			self.movechain.model=self.weaponmodel;
			self.movechain.movetype=MOVETYPE_NOCLIP;
			self.movechain.solid=SOLID_NOT;
			self.movechain.flags=self.flags; //Inky: 20200306 To allow a class-dependent model
			self.movechain.scale=self.scale; //Inky: 20200624 To allow a sizeable model
			self.movechain.skin=self.skin; //Inky: 20200628 To allow a skinable model
			self.movechain.drawflags=self.drawflags; //Inky: 20201108 To notably allow proper model scaling (especially the shepherd)
			self.movechain.effects=self.effects; //Inky: 20210922 To allow a light casting train
			precache_model2(self.movechain.model);
			setmodel (self.movechain, self.movechain.model);
			setorigin(self.movechain,self.origin+self.pos_ofs);
			if(!self.spawnflags&MODEL_AND_BRUSH)
				self.effects(+)EF_NODRAW;
			self.weaponmodel="";
			self.movechain.angles=self.angles;
			self.angles='0 0 0';
			if(self.abslight)
			{
				self.movechain.drawflags(+)MLS_ABSLIGHT;
				self.movechain.abslight=self.abslight;
			}
			if(self.spawnflags&ANGLEMATCH)//Match angles
				self.movechain.flags(+)FL_MOVECHAIN_ANGLE;
		}
		
		//Liquid train
		if (self.watertype)
		{
			if (self.watertype<-5 || self.watertype>-3)
				self.watertype = CONTENT_WATER;
				
			self.solid = SOLID_TRIGGER;
			self.touch = liquid_touch;
			
			if (self.watertype == CONTENT_WATER)
				self.puzzle_inv1 = "130 80 50 128";
			else if (self.watertype == CONTENT_SLIME)
				self.puzzle_inv1 = "0 25 5 150";
			else if (self.watertype == CONTENT_LAVA)
				self.puzzle_inv1 = "255 80 0 150";

		}
	}

	if (!self.speed)
		self.speed = 100;

	if (!self.anglespeed)
		self.anglespeed = 100;
	
	if (!self.target)
		objerror ("func_train without a target");
		
	if (!self.dmg)
		self.dmg = 2;

	if(self.health)
	{
		self.takedamage=DAMAGE_YES;
		self.th_die=chunk_death;
		if(!self.thingtype)
			self.thingtype=1;
	}

	if(self.soundtype==0 && self.noise1=="")
	{
		self.noise = self.noise1 = "misc/null.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==1)
	{
		self.noise = "plats/train2.wav";
		self.noise1 = "plats/train1.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==2)
	{
		self.noise = "plats/pulyplt2.wav";
		self.noise1 = "plats/pulyplt1.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==3)
	{
		self.noise = "plats/platstp.wav";
		self.noise1 = "plats/platslid.wav";
	}
	else if(self.soundtype==4)
	{
		self.noise = "plats/plat2.wav";
		self.noise1 = "plats/plat1.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==5)
	{
		self.noise = "plats/medplat2.wav";
		self.noise1 = "plats/medplat1.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==6)
	{
		self.noise = "plats/guiltin2.wav";
		self.noise1 = "plats/guiltin1.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==7)
	{
		self.noise = "plats/chainplt2.wav";
		self.noise1 = "plats/chainplt1.wav";
		useOldPrecache=1;
	}
	else if(self.soundtype==8)
	{
		self.noise = "plats/boldstop.wav";	//stop
		self.noise1 = "plats/boldroll.wav";	//moving
	}
	else if(self.soundtype==9)
	{
		self.noise = "plats/pwheel2.wav";
		self.noise1 = "plats/pwheel1.wav";
	}
	//Inky: 20200307 Secret door
	else if(self.soundtype==10)
	{
		self.noise = "doors/baddoor.wav";
		self.noise1 = "doors/stonslid.wav";
	}
	if(useOldPrecache)
	{
		precache_sound (self.noise);
		precache_sound (self.noise1);
	}
	else
	{
		precache_sound4 (self.noise);
		precache_sound4 (self.noise1);		
	}
	
	if(self.wait==-2)
	{
		if(!self.thingtype)
			self.thingtype=1;
		if(!self.th_die)
			self.th_die=chunk_death;
	}

	self.cnt = 1;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked_mp;
	self.use = train_use_mp;
//	self.classname = "train";
   
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
	
	targ = find(world, target, self.target);
	self.noise3 = targ.target;

	if(self.spawnflags&SLOPE)
			self.spawnflags(+)SYNCH;

	if (self.abslight)
		self.drawflags(+)MLS_ABSLIGHT;

	if (self.spawnflags & 8)
	{
		self.drawflags(+)DRF_TRANSLUCENT;
		self.solid = SOLID_NOT;
	}
		

	// start trains on the second frame, to make sure their targets have had
	// a chance to spawn
	if(self.spawnflags&PLAYER_MODEL)
		self.nextthink = self.ltime + 1; //Let's wait longer for the player to actually enter the game, otherwise player.playerclass will be 0 and an "Array out of bound" error will occur in func_train_setup_animation.
	else
		self.nextthink = self.ltime + 0.1;
	self.think = func_train_find_mp;
};

void() liquid_touch =
{
	local float test;
	local float r,g,b,i,c;
	
	if (!(other.flags & FL_CLIENT))
	{
		// Trick the C code into playing the splash sound... (even though I find it annoying as hell)
		
		// These movetypes don't splash
		if (other.movetype == MOVETYPE_NONE ||
			other.movetype == MOVETYPE_PUSH	||
			other.movetype == MOVETYPE_NOCLIP)// MOVETYPE_WALK is always FL_CLIENT so don't worry about it
			return;
		
		// Wait for the engine to assign CONTENT_EMPTY before changing watertype (just spawned)
		if (other.watertime < time && other.watertype) {					
			other.watertype = self.watertype;
			other.waterlevel = 300; //Lame hack to be sure monsters are brutally killed. With normal (3) value, they would take the initial damage then nothing else ever if in attack state
		}

		//Do damage
		if (self.watertype == CONTENT_LAVA)
		{
			if (other.dmgtime < time)
			{
				other.dmgtime = time + 0.5;

				if(other.flags2&FL2_FIREHEAL)
					other.health=other.health+5*other.waterlevel;
				else if(!other.flags2&FL2_FIRERESIST)
					T_Damage (other, world, world, 5*other.waterlevel);
				else
					T_Damage (other, world, world, 2*other.waterlevel);
			}
		}
		else if (self.watertype == CONTENT_SLIME)
		{
			if (other.dmgtime < time)
			{
				other.dmgtime = time + 1;
				T_Damage (other, world, world, 4*other.waterlevel);
			}
		}
		
		//Dead monsters explode, that's cooler!
		if(other.health <= 0)
		{
			entity oself = self;
			self = other;
			chunk_death();
			self = oself;
		}

		// C code will go nuts with the splash sound if we don't time out while in func_water
		other.watertime = time + 0.1;	
		return;
	}
	
	// Test Feet (if feet are below maxs and above mins, we're in)
	test = other.origin_z + other.mins_z + 1;
	if (test <= self.absmax_z && test >= self.absmin_z)
	{
		other.watertype = self.watertype;
		other.waterlevel = 1;
		
		// Test Torso
		test = other.origin_z + (other.mins_z + other.maxs_z) * 0.5;
		if (test <= self.absmax_z)
			other.waterlevel = 2;
		
		// Test Eyes
		test = other.origin_z + other.view_ofs_z;
		if (test <= self.absmax_z)
			other.waterlevel = 3;
	}
	
	if (other.waterlevel == 2)
	{
		other.zerogtime = time+0.05;// remove gravity in PreThink
	}
	else if (other.waterlevel == 3)
	{
		// Do the color shift
		stuffcmd(other, "v_cshift ");
		stuffcmd(other, self.puzzle_inv1); //self.puzzle_inv1 actually stores the color shift
		stuffcmd(other, "\n");

		// Tell PreThink to clear the cshift when the player is out
		other.watertime = time+frametime;
		other.watershift = TRUE;
	}
};

// Silly hack to ensure cshift happens for dead players
void() CheckLiquidTrainDeath =
{
	local entity ent;
	local vector spot, rgb;
	local float	 i;
	
	spot = self.origin + self.view_ofs;
	ent = find(world, classname, "func_train_mp");

	while(ent)
	{
		// FIXME! - do this right?
		if (  ent.watertype  /*Liquid train*/ &&
			 (spot_x<ent.absmax_x) &&
			 (spot_y<ent.absmax_y) &&
			 (spot_z<ent.absmax_z) &&
			 (spot_x>ent.absmin_x) && 
			 (spot_y>ent.absmin_y) && 
			 (spot_z>ent.absmin_z))
		{
						
			// Do the color shift
			stuffcmd(self, "v_cshift ");
			stuffcmd(self, ent.puzzle_inv1);
			stuffcmd(self, "\n");

			self.watertime = time+frametime;
			self.watershift = TRUE;			
			
			return;// Done (or else someone made a retarded map)
		}
		
		ent = find(ent, classname, "func_train_mp");
	}
};