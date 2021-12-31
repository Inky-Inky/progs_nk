void() monster_archer;
void() monster_archer_ice;
void() monster_fallen_angel;
void() monster_hydra;
void() monster_imp_fire;
void() monster_imp_ice;
void() monster_scorpion_black;
void() monster_scorpion_yellow;
void() monster_skull_wizard;
void() monster_spider_red_large;
void() monster_spider_red_small;
void() monster_spider_yellow_large;
void() monster_spider_yellow_small;
void() monster_weresnowleopard;
void() monster_weretiger;
void() monster_yakman;

void(vector org, entity death_owner) spawn_tdeath;

float monster_spawn_precache_nk ()
{
	float have_monsters;
	if(self.headmodel=="monster_archer")
	{
		precache_archer();
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_archer_ice")
	{
		precache_model4("models/archer2.mdl");
		precache_model4("models/akarrow2.mdl");
		precache_sound4 ("archer/arrowg2.wav");

		precache_sound ("archer/arrowg.wav");
		precache_sound ("archer/arrowr.wav");

		precache_model("models/archerhd.mdl");

		precache_model("models/gspark.spr");

		precache_sound ("archer/growl.wav");
		precache_sound ("archer/pain.wav");
		precache_sound ("archer/sight.wav");
		precache_sound ("archer/death.wav");
		precache_sound ("archer/draw.wav");
		have_monsters=TRUE;
	}
	else if(self.headmodel=="monster_fallen_angel")
	{
		precache_model4 ("models/fangel.mdl");//converted for MP
		precache_model2 ("models/faspell.mdl");
		precache_model2 ("models/fablade.mdl");
		precache_model4 ("models/h_fangel.mdl");
		precache_sound2("fangel/fly.wav");
		precache_sound2("fangel/deflect.wav");
		precache_sound2("fangel/hand.wav");
		precache_sound2("fangel/wing.wav");
		precache_sound2("fangel/ambi1.wav");
		precache_sound2("fangel/death.wav");
		precache_sound2("fangel/pain.wav");
		have_monsters=TRUE;
	}
	else if(self.headmodel=="monster_imp_fire")
	{
		precache_model4 ("models/imp.mdl");//converted for MP
		precache_model3 ("models/h_imp.mdl");//empty for now
		precache_sound3("imp/up.wav");
		precache_sound3("imp/die.wav");
		precache_sound3("imp/swoop.wav");
		precache_sound3("imp/fly.wav");
		precache_model3 ("models/shardice.mdl");
		precache_model ("models/fireball.mdl");
		precache_sound3("imp/swoophit.wav");
		precache_sound3("imp/fireball.wav");
		precache_sound3("imp/shard.wav");
		precache_sound("hydra/turn-s.wav");
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_imp_ice")
	{
		precache_model4 ("models/imp.mdl");//converted for MP
		precache_model3 ("models/h_imp.mdl");//empty for now
		precache_sound3("imp/up.wav");
		precache_sound3("imp/die.wav");
		precache_sound3("imp/swoop.wav");
		precache_sound3("imp/fly.wav");
		precache_model3 ("models/shardice.mdl");
		precache_sound3("imp/swoophit.wav");
		precache_sound3("imp/fireball.wav");
		precache_sound3("imp/shard.wav");
		precache_sound("hydra/turn-s.wav");
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_scorpion_yellow" || self.headmodel=="monster_scorpion_black")
	{
		precache_model2("models/scorpion.mdl");
		precache_sound2("scorpion/awaken.wav");
		precache_sound2("scorpion/walk.wav");
		precache_sound2("scorpion/clawsnap.wav");
		precache_sound2("scorpion/tailwhip.wav");
		precache_sound2("scorpion/pain.wav");
		precache_sound2("scorpion/death.wav");
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_skull_wizard")
	{
		precache_model4("models/skullwiz.mdl");//converted for MP
		precache_model("models/skulbook.mdl");
		precache_model("models/skulhead.mdl");
		precache_model("models/skulshot.mdl");
		precache_model("models/spider.mdl");
		precache_sound("skullwiz/death.wav");
		precache_sound("skullwiz/blinkspk.wav");
		precache_sound("skullwiz/growl.wav");
		precache_sound("skullwiz/scream.wav");
		precache_sound("skullwiz/pain.wav");
		precache_sound("skullwiz/gate.wav");
		precache_sound("skullwiz/blinkin.wav");
		precache_sound("skullwiz/blinkout.wav");
		precache_sound("skullwiz/push.wav");
		precache_sound("skullwiz/firemisl.wav");
		precache_spider();
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_spider_yellow_small" || self.headmodel=="monster_spider_yellow_large" || self.headmodel=="monster_spider_red_small" || self.headmodel=="monster_spider_red_large")
	{
		precache_spider();
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_weresnowleopard")
	{
		precache_model4 ("models/snowleopard.mdl");
		precache_model2 ("models/mezzoref.spr");
		precache_model2 ("models/h_mez.mdl");
		precache_sound2 ("mezzo/skid.wav");
		precache_sound2 ("mezzo/roar.wav");
		precache_sound2 ("mezzo/reflect.wav");
		precache_sound2 ("mezzo/slam.wav");
		precache_sound2 ("mezzo/pain.wav");
		precache_sound2 ("mezzo/die.wav");
		precache_sound2 ("mezzo/growl.wav");
		precache_sound2 ("mezzo/snort.wav");
		precache_sound2 ("mezzo/attack.wav");
		have_monsters=TRUE;		
	}
	else if(self.headmodel=="monster_weretiger")
	{
		precache_model4 ("models/snowleopard.mdl");
		precache_model2 ("models/mezzoref.spr");
		precache_model2 ("models/h_mez2.mdl");
		precache_sound2 ("mezzo/skid.wav");
		precache_sound2 ("mezzo/roar.wav");
		precache_sound2 ("mezzo/reflect.wav");
		precache_sound2 ("mezzo/slam.wav");
		precache_sound2 ("mezzo/pain.wav");
		precache_sound2 ("mezzo/die.wav");
		precache_sound2 ("mezzo/growl.wav");
		precache_sound2 ("mezzo/snort.wav");
		precache_sound2 ("mezzo/attack.wav");
		have_monsters=TRUE;
	}
	else if(self.headmodel=="monster_yakman")
	{
		precache_model4 ("models/yakman.mdl");
		precache_model4 ("models/yakball.mdl");
		precache_model2 ("models/iceshot2.mdl");
		precache_model4 ("models/powersh.mdl");
		precache_model4 ("models/sheepmis.mdl");
		precache_sound4 ("yakman/slam.wav");
		precache_sound4 ("yakman/pain.wav");
		precache_sound4 ("yakman/hoof.wav");
		precache_sound4 ("yakman/grunt.wav");
		precache_sound4 ("yakman/snort1.wav");
		precache_sound4 ("yakman/snort2.wav");
		precache_sound4 ("yakman/roar.wav");
		precache_sound4 ("yakman/die.wav");
		precache_sound3 ("crusader/icewall.wav");	
		precache_sound4 ("yakman/icespell.wav");	
		precache_sound3 ("crusader/icefire.wav");	
		precache_sound3 ("misc/tink.wav");				//Ice shots bounce
		precache_sound3 ("mezzo/skid.wav");
		have_monsters=TRUE;		
	}
	
	return have_monsters;
}

void() FoundTarget;

void MakeAngry(void)
{
	self.goalentity.think = FoundTarget;
	remove(self);
}

float check_monsterspawn_nk_ok (void)
{
vector org;

	org=self.origin;

	tracearea(org,org,self.mins,self.maxs,FALSE,self);
	newmis = spawn();
	if(trace_fraction<1)
		if(trace_ent.flags2&FL_ALIVE&&!self.frags)
		{
			remove(newmis);
			return FALSE;
		}
		else
			spawn_tdeath(trace_ent.origin,newmis);

	newmis.angles = self.angles;
	newmis.flags2+=FL_SUMMONED;

	newmis.classname = self.headmodel;
	
	     if(self.headmodel=="monster_archer")              newmis.think = monster_archer;
	else if(self.headmodel=="monster_archer_ice")          newmis.think = monster_archer_ice;
	else if(self.headmodel=="monster_fallen_angel")        newmis.think = monster_fallen_angel;
	else if(self.headmodel=="monster_imp_fire")            newmis.think = monster_imp_fire;
	else if(self.headmodel=="monster_imp_ice")             newmis.think = monster_imp_ice;
	else if(self.headmodel=="monster_scorpion_yellow")     newmis.think = monster_scorpion_yellow;
	else if(self.headmodel=="monster_scorpion_black")      newmis.think = monster_scorpion_black;
	else if(self.headmodel=="monster_skull_wizard")        newmis.think = monster_skull_wizard;
	else if(self.headmodel=="monster_spider_yellow_small") newmis.think = monster_spider_yellow_small;
	else if(self.headmodel=="monster_spider_yellow_large") newmis.think = monster_spider_yellow_large;
	else if(self.headmodel=="monster_spider_red_small")    newmis.think = monster_spider_red_small;
	else if(self.headmodel=="monster_spider_red_large")    newmis.think = monster_spider_red_large;
	else if(self.headmodel=="monster_weresnowleopard")     newmis.think = monster_weresnowleopard;
	else if(self.headmodel=="monster_weretiger")           newmis.think = monster_weretiger;
	else if(self.headmodel=="monster_yakman")              newmis.think = monster_yakman;

	self.goalentity=newmis;
	setorigin(newmis,org);
	
	//Fire its targets when giving birth to a new monster
	//Especially useful to set up the newly born with specific properties thanks to trigger_setproperty with target set to activator.goalentity
	if(self.target)
	{
		activator = other = self;
		SUB_UseTargets();
	}
	
	//Angry at player right away!
	if(self.spawnflags&4/*Angry at player*/)
	{
		entity angryAt = find (world, classname, "player");
		if(angryAt)
		{
			entity angryMaker = spawn();
			angryMaker.goalentity=newmis;
			angryMaker.think = MakeAngry;
			angryMaker.nextthink = 0.5;
		}
	}
	
	newmis.nextthink = time;
	return TRUE;
}

void monsterspawn_active_nk (void)
{
	self.think=monsterspawn_active_nk;
	if(check_monsterspawn_nk_ok())
	{
		if(!self.spawnflags&1/*Quiet*/)
		{
			if(self.spawnflags&2/*Big teleport effect*/)
				GenerateTeleportEffect(self.goalentity.origin,0);
			else
				spawn_tfog(self.goalentity.origin);
		}
	}
	else
		self.nextthink=time+0.1; //After a failed spawn, wait 0.1 seconds to try again
}

/*QUAKED func_monsterspawner_nk (1 .8 0) (-16 -16 0) (16 16 56) QUIET BIG ANGRY
If something is blocking the spawnspot, this will telefrag it as long as it's not a living entity (flags2&FL_ALIVE)

The Monsters will be spawned at the origin of the spawner, so if you want them not to stick in the ground, put this above the ground some- maybe 24?  Make sure there's enough room around it for the monsters.

QUIET = No particles, no sound
BIG = teleport effect more noticeable (the one usually used for sheep transformation)
ANGRY = Monster chases the player right away, even if out of sight
targetname = not needed unless you plan to activate this with a trigger
*/
void func_monsterspawner_nk (void)
{
	setsize(self,'-16 -16 0','16 16 56');
	setorigin(self,self.origin);

	if(!monster_spawn_precache_nk())
	{
		dprint("func_monsterspawner_nk doesn't have any monsters assigned to it!\n");
		remove(self);
	}

	if(self.targetname)
		self.use=monsterspawn_active_nk;
	else
	{
		self.think=monsterspawn_active_nk;
		self.nextthink=time+3;//wait while map starts
	}
}


