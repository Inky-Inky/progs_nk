/*QUAKED misc_modelpimp by Inky (11/2021)
An entity able to pimp the properties of a model (like rotation, glow, dynamic light, etc.)
flags	ignore the hard coded flags in the mdl file and use those instead
		Caution : the value set in flags is ignored if the "Showcase mode" is active because of "using" the entity
		          if so the flags value is handled by code automatically and each call to .use
				  applies a different flag value for flags testing purpose
*/
string FlagFriendlyNames[25] =
{
	"_Rocket smoke trail",
	"_Grenade smoke trail",
	"_Gib long blood trail",
	"_Rotate",
	"_Scrag double green trail",
	"_Zombie gib short blood trail",
	"_Hellknight orange split trail",
	"_Vore purple trail",
	"_Fireball",
	"_Ice trail",
	"_Mipmap",
	"_Ink spit",
	"_Transparent sprite",
	"_Vertical spray",
	"_Holey (fence) texture",
	"_Translucent",
	"_Always facing player",
	"_Bottom & top trail",
	"_Slow staff move",
	"_Blue/white magic drip",
	"_Bone shards drip",
	"_Scarab dust",
	"_Acid ball",
	"_Blood rain",
	"_Far mipmap"
};

float modelpimp_showcase()
{
	//Advance the flags for the next call
	if(self.flags == 16777216)
	{
		self.walkframe = 0;
		self.flags = 1; //We've come full circle, back to the beginning
	}
	else
	{
		self.walkframe = self.walkframe + 1;
		if(self.flags == 0) self.flags = 1; else self.flags = self.flags * 2; //Next value 
	}
	entity player = find (world, classname, "player");
	centerprint(player,FlagFriendlyNames[self.walkframe]);

	return pimpmodel(self, self.glow_color);
}

void modelpimp_think ()
{
	pimpmodel(self, self.glow_color);
	
	//Do it again later (a small delay is mandatory when (re)loading a map; trying to pimp the model right away would come too early and fail)
	self.nextthink = time + self.wait;
}

void() misc_modelpimp =
{
	precache_model(self.model);
	setmodel(self, self.model);
	self.effects(+)EF_NODRAW;
	
	if(!self.wait) self.wait = 0.5;
	
	if(self.targetname)
	{
		self.use = modelpimp_showcase;
		self.walkframe = -1;
		self.flags = 0;
	}
	
	self.think = modelpimp_think;
	self.nextthink = time + self.wait;
}