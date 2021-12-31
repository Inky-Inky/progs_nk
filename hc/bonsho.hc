void ring_core (void)
{
	self.nextthink = time + HX_FRAME_TIME + HX_FRAME_TIME + HX_FRAME_TIME;

	if (cycle_wrapped)
	{
		self.frame = 0;
		self.nextthink = time - 1;
		self.think = SUB_Null;
	}	
}
void bonsho_anim (void) [++ 0 .. 7]
{
	ring_core();
}

void bonsho_anim_reverse (void) [-- 7 .. 0]
{
	ring_core();
}

void bonsho_use (void)
{
	if (other.ideal_yaw == -1)
	{
		self.frame = 7;
		bonsho_anim_reverse();
	}
	else
	{
		self.frame = 0;
		bonsho_anim();
	}
	
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
}

void bonsho_hit (void)
{
	self.health = 5000;
	sound (self, CHAN_WEAPON, "weapons/met2met.wav", 1, ATTN_NORM);
}

/*QUAKED obj_bonsho (0.3 0.1 0.6) (-100 -100 -210) (100 100 8)
A bonsho bell that rings when hit. 
-------------------------FIELDS-------------------------
spawnflags (determines its size and note)
--------------------------------------------------------
*/
void obj_bonsho (void)
{
	SetMovedir();
	
	//Precache
	     if(self.spawnflags& 2/*La */)	{ self.noise = "bonsho/la.wav"; self.scale = 0.75; }
	else if(self.spawnflags& 4/*Si */)	{ self.noise = "bonsho/si.wav"; self.scale = 0.60; }
	else if(self.spawnflags& 8/*Do */)	{ self.noise = "bonsho/do.wav"; self.scale = 0.30; }
	else if(self.spawnflags&16/*Ré */)	{ self.noise = "bonsho/re.wav"; self.scale = 0.20; }
	else                     /*Sol*/	{ self.noise = "bonsho/sol.wav"; }
	
	precache_sound(self.noise);
	
	//Properties
	precache_model("models/bonsho.mdl");
	setmodel(self, "models/bonsho.mdl");
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_SLIDEBOX;
	self.thingtype = THINGTYPE_FIRE;
	setsize(self,'-70 -70 -230', '70 70 8');
	self.takedamage = DAMAGE_YES;
	self.health = 5000;
	if (self.abslight) self.drawflags(+)MLS_ABSLIGHT;

	self.th_pain = bonsho_hit;
	self.use     = bonsho_use;
}
